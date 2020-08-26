class UniversalPython < Requirement
  satisfy(:build_env => false) { archs_for_command("python").universal? }

  def message; <<-EOS.undent
    A universal build was requested, but Python is not a universal build

    Boost compiles against the Python it finds in the path; if this Python
    is not a universal build then linking will likely fail.
    EOS
  end
end

class UniversalPython3 < Requirement
  satisfy(:build_env => false) { archs_for_command("python3").universal? }

  def message; <<-EOS.undent
    A universal build was requested, but Python 3 is not a universal build

    Boost compiles against the Python 3 it finds in the path; if this Python
    is not a universal build then linking will likely fail.
    EOS
  end
end

class Boost155 < Formula
  desc "Collection of portable C++ source libraries"
  homepage "http://www.boost.org"
  revision 1

  stable do
    url "https://downloads.sourceforge.net/project/boost/boost/1.55.0/boost_1_55_0.tar.bz2"
    sha256 "fff00023dd79486d444c8e29922f4072e1d451fc5a4d2b6075852ead7f2b7b52"

    # Patches boost::atomic for LLVM 3.4 as it is used on OS X 10.9 with Xcode 5.1
    # https://github.com/Homebrew/homebrew/issues/27396
    # https://github.com/Homebrew/homebrew/pull/27436
    patch :p2 do
      url "https://github.com/boostorg/atomic/commit/6bb71fdd.diff"
      sha256 "eb139160a33d8ef3e810ce3e47da278563d03d7be6d0a75c109f708030a7abcb"
    end

    patch :p2 do
      url "https://github.com/boostorg/atomic/commit/e4bde20f.diff"
      sha256 "8c5efeea91d44b2a48fdeee9cde71e831dad78f0930e8f65b7223ba0ecdfec9b"
    end

    # Patch fixes upstream issue reported here (https://svn.boost.org/trac/boost/ticket/9698).
    # Will be fixed in Boost 1.56 and can be removed once that release is available.
    # See this issue (https://github.com/Homebrew/homebrew/issues/30592) for more details.

    patch :p2 do
      url "https://github.com/boostorg/chrono/commit/143260d.diff"
      sha256 "f6f40b576725b15ddfe24497ddcd597f387dfdf674f6dd301b8dcb723593ee22"
    end
  end

  bottle do
    cellar :any
    rebuild 1
    sha256 "47f288321a2a3a0aade80312484f0ab66274b5663d12c4af7c98065bf5c5de32" => :sierra
    sha256 "a0c12015fb98746ffa335f6db5fefc5e6c70e120c98f36d6e21f71b14fbc484e" => :el_capitan
    sha256 "89301e28dbc76813de061c2350e6dced9861d9bd37ef9feb646233a8b50e8c88" => :yosemite
    sha256 "1d3367159ddd35b26339402255e36fff7ff9d609be1a8cea4a7508a04b7de67b" => :mavericks
  end

  keg_only "Conflicts with boost in main repository."

  env :userpaths

  option :universal
  option "with-icu", "Build regexp engine with icu support"
  option "without-single", "Disable building single-threading variant"
  option "without-static", "Disable building static library variant"
  option "with-mpi", "Build with MPI support"
  option :cxx11

  depends_on :python => :optional
  depends_on :python3 => :optional
  depends_on UniversalPython if build.universal? && build.with?("python")
  depends_on UniversalPython3 if build.universal? && build.with?("python3")

  if build.with?("python3") && build.with?("python")
    odie "boost155: --with-python3 cannot be specified when using --with-python"
  end

  if build.with? "icu"
    if build.cxx11?
      depends_on "icu4c" => "c++11"
    else
      depends_on "icu4c"
    end
  end

  if build.with? "mpi"
    if build.cxx11?
      depends_on "open-mpi" => "c++11"
    else
      depends_on :mpi => [:cc, :cxx, :optional]
    end
  end

  def install
    # Patch boost::serialization for Clang
    # https://svn.boost.org/trac/boost/raw-attachment/ticket/8757/0005-Boost.S11n-include-missing-algorithm.patch
    inreplace "boost/archive/iterators/transform_width.hpp",
      "#include <boost/iterator/iterator_traits.hpp>",
      "#include <boost/iterator/iterator_traits.hpp>\n#include <algorithm>"

    # https://svn.boost.org/trac/boost/ticket/8841
    if build.with?("mpi") && build.with?("single")
      raise <<-EOS.undent
        Building MPI support for both single and multi-threaded flavors
        is not supported.  Please use "--with-mpi" together with
        "--without-single".
      EOS
    end

    if build.cxx11? && build.with?("mpi") && (build.with?("python") \
                                               || build.with?("python3"))
      raise <<-EOS.undent
        Building MPI support for Python using C++11 mode results in
        failure and hence disabled.  Please don"t use this combination
        of options.
      EOS
    end

    ENV.universal_binary if build.universal?

    # Force boost to compile using the appropriate GCC version.
    open("user-config.jam", "a") do |file|
      file.write "using darwin : : #{ENV.cxx} ;\n"
      file.write "using mpi ;\n" if build.with? "mpi"

      # Link against correct version of Python if python3 build was requested
      if build.with? "python3"
        py3executable = `which python3`.strip
        py3version = `python3 -c "import sys; print(sys.version[:3])"`.strip
        py3prefix = `python3 -c "import sys; print(sys.prefix)"`.strip

        file.write <<-EOS.undent
          using python : #{py3version}
                       : #{py3executable}
                       : #{py3prefix}/include/python#{py3version}m
                       : #{py3prefix}/lib ;
        EOS
      end
    end

    # we specify libdir too because the script is apparently broken
    bargs = ["--prefix=#{prefix}", "--libdir=#{lib}"]

    if build.with? "icu"
      icu4c_prefix = Formula["icu4c"].opt_prefix
      bargs << "--with-icu=#{icu4c_prefix}"
    else
      bargs << "--without-icu"
    end

    # Handle libraries that will not be built.
    without_libraries = []

    # The context library is implemented as x86_64 ASM, so it
    # won"t build on PPC or 32-bit builds
    # see https://github.com/Homebrew/homebrew/issues/17646
    if Hardware::CPU.ppc? || Hardware::CPU.is_32_bit? || build.universal?
      without_libraries << "context"
      # The coroutine library depends on the context library.
      without_libraries << "coroutine"
    end

    # Boost.Log cannot be built using Apple GCC at the moment. Disabled
    # on such systems.
    without_libraries << "log" if ENV.compiler == :gcc
    without_libraries << "python" if build.without?("python") \
                                      && build.without?("python3")
    without_libraries << "mpi" if build.without? "mpi"

    bargs << "--without-libraries=#{without_libraries.join(",")}"

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

    system "./bootstrap.sh", *bargs
    system "./b2", *args
  end

  def caveats
    s = ""
    # ENV.compiler doesn"t exist in caveats. Check library availability
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
      #include <boost/version.hpp>
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

        assert(strcmp(BOOST_LIB_VERSION, "1_55") == 0);

        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-std=c++1y", "-I#{include}", "-L#{lib}", "-lboost_system", "-o", "test"
    system "./test"
  end
end
