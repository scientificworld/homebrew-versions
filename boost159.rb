class Boost159 < Formula
  desc "Collection of portable C++ source libraries"
  homepage "http://www.boost.org"
  url "https://downloads.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.bz2"
  sha256 "727a932322d94287b62abb1bd2d41723eec4356a7728909e38adb65ca25241ca"

  bottle do
    cellar :any
    sha256 "e97d62e699f3766d1e088df2bdd98a4ec76f168b383ba6595b1e116a4c63cdac" => :sierra
    sha256 "0eed018a20e25f55ff029376a899f3b73817d9a49fafae0c9488689d27cd3643" => :el_capitan
    sha256 "7d90dac3983b8ae5e844396d0baf43e365b79b4040829fdbaa925c5916649654" => :yosemite
    sha256 "a7f928a08e8add78570ab19ab54d78211c754ed0947ee5aa9d6896b10cdccb04" => :mavericks
  end

  keg_only "Conflicts with boost in main repository."

  option :universal
  option "with-icu4c", "Build regexp engine with icu support"
  option "without-single", "Disable building single-threading variant"
  option "without-static", "Disable building static library variant"
  option "with-mpi", "Build with MPI support"
  option :cxx11

  if build.cxx11?
    depends_on "icu4c" => [:optional, "c++11"]
    depends_on "open-mpi" => "c++11" if build.with? "mpi"
  else
    depends_on "icu4c" => :optional
    depends_on :mpi => [:cc, :cxx, :optional]
  end

  # Fixed compilation of operator<< into a record ostream, when
  # the operator right hand argument is not directly supported by
  # formatting_ostream. Fixed https://svn.boost.org/trac/boost/ticket/11549
  # from https://github.com/boostorg/log/commit/7da193f.patch
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/2ccb6715b3/boost/boost159-questionable-operator.patch"
    sha256 "a49fd7461d9f3b478d2bddac19adca93fe0fabab71ee67e8f140cbd7d42d6870"
  end

  # Fixed missing symbols in libboost_log_setup (on mac/clang)
  # from https://github.com/boostorg/log/commit/870284ed31792708a6139925d00a0aadf46bf09f
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/2ccb6715b3/boost/boost159-missing-symbols.patch"
    sha256 "2c3a3bae1691df5f8fce8fbd4e5727d57bd4dd813748b70d7471c855c4f19d1c"
  end

  needs :cxx11 if build.cxx11?

  def install
    # https://svn.boost.org/trac/boost/ticket/8841
    if build.with?("mpi") && build.with?("single")
      raise <<-EOS.undent
        Building MPI support for both single and multi-threaded flavors
        is not supported.  Please use "--with-mpi" together with
        "--without-single".
      EOS
    end

    ENV.universal_binary if build.universal?

    # Force boost to compile with the desired compiler
    open("user-config.jam", "a") do |file|
      file.write "using darwin : : #{ENV.cxx} ;\n"
      file.write "using mpi ;\n" if build.with? "mpi"
    end

    # libdir should be set by --prefix but isn't
    bootstrap_args = ["--prefix=#{prefix}", "--libdir=#{lib}"]

    if build.with? "icu4c"
      icu4c_prefix = Formula["icu4c"].opt_prefix
      bootstrap_args << "--with-icu=#{icu4c_prefix}"
    else
      bootstrap_args << "--without-icu"
    end

    # Handle libraries that will not be built.
    without_libraries = ["python"]

    # The context library is implemented as x86_64 ASM, so it
    # won't build on PPC or 32-bit builds
    # see https://github.com/Homebrew/homebrew/issues/17646
    if Hardware::CPU.ppc? || Hardware::CPU.is_32_bit? || build.universal?
      without_libraries << "context"
      # The coroutine library depends on the context library.
      without_libraries << "coroutine"
    end

    # Boost.Log cannot be built using Apple GCC at the moment. Disabled
    # on such systems.
    without_libraries << "log" if ENV.compiler == :gcc
    without_libraries << "mpi" if build.without? "mpi"

    bootstrap_args << "--without-libraries=#{without_libraries.join(",")}"

    # layout should be synchronized with boost-python
    args = ["--prefix=#{prefix}",
            "--libdir=#{lib}",
            "-d2",
            "-j#{ENV.make_jobs}",
            "--layout=tagged",
            "--user-config=user-config.jam",
            "install"]

    if build.with? "single"
      args << "threading=multi,single"
    else
      args << "threading=multi"
    end

    if build.with? "static"
      args << "link=shared,static"
    else
      args << "link=shared"
    end

    args << "address-model=32_64" << "architecture=x86" << "pch=off" if build.universal?

    # Trunk starts using "clang++ -x c" to select C compiler which breaks C++11
    # handling using ENV.cxx11. Using "cxxflags" and "linkflags" still works.
    if build.cxx11?
      args << "cxxflags=-std=c++11"
      if ENV.compiler == :clang
        args << "cxxflags=-stdlib=libc++" << "linkflags=-stdlib=libc++"
      end
    end

    system "./bootstrap.sh", *bootstrap_args
    system "./b2", "headers"
    system "./b2", *args
  end

  def caveats
    s = ""
    # ENV.compiler doesn't exist in caveats. Check library availability
    # instead.
    if Dir["#{lib}/libboost_log*"].empty?
      s += <<-EOS.undent

      Building of Boost.Log is disabled because it requires newer GCC or Clang.
      EOS
    end

    if Hardware::CPU.ppc? || Hardware::CPU.is_32_bit? || build.universal?
      s += <<-EOS.undent

      Building of Boost.Context and Boost.Coroutine is disabled as they are
      only supported on x86_64.
      EOS
    end

    s
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <boost/algorithm/string.hpp>
      #include <string>
      #include <vector>
      #include <assert.h>
      using namespace boost::algorithm;
      using namespace std;

      int main()
      {
        string str("a,b");
        vector<string> strVec;
        split(strVec, str, is_any_of(","));
        assert(strVec.size()==2);
        assert(strVec[0]=="a");
        assert(strVec[1]=="b");
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-std=c++1y", "-I#{include}", "-L#{lib}",
                                "-lboost_system", "-o", "test"
    system "./test"
  end
end
