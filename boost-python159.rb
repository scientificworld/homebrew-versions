class BoostPython159 < Formula
  desc "C++ library for C++/Python interoperability"
  homepage "http://www.boost.org"
  url "https://downloads.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.bz2"
  sha256 "727a932322d94287b62abb1bd2d41723eec4356a7728909e38adb65ca25241ca"

  bottle do
    cellar :any
    sha256 "d1cd9a2d1dc6702e498ab00cc08a3bc209810c1d90ab6f5f6562acf446640728" => :sierra
    sha256 "455c3e4253bc5e7dce422e217aaff2a4361a15e8789daa49901105aa111b52b5" => :el_capitan
    sha256 "a4d5a6a41654e43e025e38eb6a87db901fea072dec6c9c8e1900cbd1973f5481" => :yosemite
    sha256 "c6e99c0f1ca29a1ba90777cb84cd23cb3532060101c386bcfc8bc40b4fd6ca61" => :mavericks
  end

  keg_only "Conflicts with boost-python in main repository."

  option :universal
  option :cxx11

  option "without-python", "Build without python 2 support"
  depends_on python3 => :optional

  if build.cxx11?
    depends_on "boost159" => "c++11"
  else
    depends_on "boost159"
  end

  def install
    ENV.universal_binary if build.universal?

    # fix make_setter regression
    # https://github.com/boostorg/python/pull/40
    inreplace "boost/python/data_members.hpp",
              "# if BOOST_WORKAROUND(__EDG_VERSION__, <= 238)",
              "# if !BOOST_WORKAROUND(__EDG_VERSION__, <= 238)"

    # "layout" should be synchronized with boost
    args = ["--prefix=#{prefix}",
            "--libdir=#{lib}",
            "-d2",
            "-j#{ENV.make_jobs}",
            "--layout=tagged",
            "--user-config=user-config.jam",
            "threading=multi,single",
            "link=shared,static"]

    args << "address-model=32_64" << "architecture=x86" << "pch=off" if build.universal?

    # Build in C++11 mode if boost was built in C++11 mode.
    # Trunk starts using "clang++ -x c" to select C compiler which breaks C++11
    # handling using ENV.cxx11. Using "cxxflags" and "linkflags" still works.
    if build.cxx11?
      args << "cxxflags=-std=c++11"
      if ENV.compiler == :clang
        args << "cxxflags=-stdlib=libc++" << "linkflags=-stdlib=libc++"
      end
    elsif Tab.for_name("boost159").cxx11?
      odie "boost159 was built in C++11 mode so boost-python159 must be built with --c++11."
    end

    # disable python detection in bootstrap.sh; it guesses the wrong include directory
    # for Python 3 headers, so we configure python manually in user-config.jam below.
    inreplace "bootstrap.sh", "using python", "#using python"

    Language::Python.each_python(build) do |python, version|
      py_prefix = `#{python} -c "from __future__ import print_function; import sys; print(sys.prefix)"`.strip
      py_include = `#{python} -c "from __future__ import print_function; import distutils.sysconfig; print(distutils.sysconfig.get_python_inc(True))"`.strip
      open("user-config.jam", "w") do |file|
        # Force boost to compile with the desired compiler
        file.write "using darwin : : #{ENV.cxx} ;\n"
        file.write <<-EOS.undent
          using python : #{version}
                       : #{python}
                       : #{py_include}
                       : #{py_prefix}/lib ;
        EOS
      end

      system "./bootstrap.sh", "--prefix=#{prefix}", "--libdir=#{lib}", "--with-libraries=python",
                               "--with-python=#{python}", "--with-python-root=#{py_prefix}"

      system "./b2", "--build-dir=build-#{python}", "--stagedir=stage-#{python}",
                     "python=#{version}", *args
    end

    lib.install Dir["stage-python3/lib/*py*"] if build.with?("python3")
    lib.install Dir["stage-python/lib/*py*"] if build.with?("python")
    doc.install Dir["libs/python/doc/*"]
  end

  test do
    (testpath/"hello.cpp").write <<-EOS.undent
      #include <boost/python.hpp>
      char const* greet() {
        return "Hello, world!";
      }
      BOOST_PYTHON_MODULE(hello)
      {
        boost:python::def("greet", greet);
      }
    EOS
    Language::Python.each_python(build) do |python, _|
      pyflags = (`#{python}-config --includes`.strip +
                 `#{python}-config --ldflags`.strip).split(" ")
      system ENV.cxx, "-shared", "hello.cpp", "-I#{Formula["boost159"].opt_include}",
                      "-L#{lib}", "-lboost_#{python}", "-o", "hello.so", *pyflags
      output = `#{python} -c "from __future__ import print_function; import hello; print(hello.greet())"`
      assert_match "Hello, world!", output
    end
  end
end
