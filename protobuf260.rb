class Protobuf260 < Formula
  desc "Protocol buffers - Google data interchange format"
  homepage "https://github.com/google/protobuf/"

  stable do
    url "https://github.com/google/protobuf/releases/download/v2.6.0/protobuf-2.6.0.tar.bz2"
    sha256 "0a2f8533b2e0587a2b4efce0c4c8aea21bbfae1c41c466634d958dedf580f6aa"

    # Fixes the unexpected identifier error when compiling software against protobuf:
    # https://github.com/google/protobuf/issues/549
    patch :p1, :DATA
  end
  bottle do
    sha256 "53b6c7640cf6cf19afef8710f26fe4a101340a89f09b2d05336dfc6b049141fa" => :yosemite
    sha256 "90e7758986b353281bce35836c358035c520e8ace182d72a1751a61a8607fa7d" => :mavericks
    sha256 "3da3651216bd105e9611fa14ecffb591eebb20c79b261f5038d11f812f851137" => :mountain_lion
  end

  # this will double the build time approximately if enabled
  option "with-check", "Run build-time check"

  option :universal
  option :cxx11

  option "without-python", "Build without python support"
  depends_on python => :recommended if MacOS.version <= :snow_leopard

  conflicts_with "protobuf", :because => "Differing versions of same formula"

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.9.0.tar.gz"
    sha256 "e24052411fc4fbd1f672635537c3fc2330d9481b18c0317695b46259512c91d5"
  end

  resource "python-dateutil" do
    url "https://pypi.python.org/packages/source/p/python-dateutil/python-dateutil-2.4.1.tar.bz2"
    sha256 "a9f62b12e28f11c732ad8e255721a9c7ab905f9479759491bc1f1e91de548d0f"
  end

  resource "pytz" do
    url "https://pypi.python.org/packages/source/p/pytz/pytz-2014.10.tar.bz2"
    sha256 "387f968fde793b142865802916561839f5591d8b4b14c941125eb0fca7e4e58d"
  end

  resource "python-gflags" do
    url "https://pypi.python.org/packages/source/p/python-gflags/python-gflags-2.0.tar.gz"
    sha256 "0dff6360423f3ec08cbe3bfaf37b339461a54a21d13be0dd5d9c9999ce531078"
  end

  resource "google-apputils" do
    url "https://pypi.python.org/packages/source/g/google-apputils/google-apputils-0.4.2.tar.gz"
    sha256 "47959d0651c32102c10ad919b8a0ffe0ae85f44b8457ddcf2bdc0358fb03dc29"
  end

  def install
    # Don't build in debug mode. See:
    # https://github.com/Homebrew/homebrew/issues/9279
    # http://code.google.com/p/protobuf/source/browse/trunk/configure.ac#61
    ENV.prepend "CXXFLAGS", "-DNDEBUG"
    ENV.universal_binary if build.universal?
    ENV.cxx11 if build.cxx11?

    system "./configure", "--disable-debug", "--disable-dependency-tracking",
           "--prefix=#{prefix}",
           "--with-zlib"
    system "make"
    system "make", "check" if (build.with? "check") || build.bottle?
    system "make", "install"

    # Install editor support and examples
    doc.install "editors", "examples"

    if build.with? "python"
      # google-apputils is a build-time dependency
      ENV.prepend_create_path "PYTHONPATH", buildpath/"homebrew/lib/python2.7/site-packages"
      %w[six python-dateutil pytz python-gflags google-apputils].each do |package|
        resource(package).stage do
          system "python", *Language::Python.setup_install_args(buildpath/"homebrew")
        end
      end
      # google is a namespace package and .pth files aren't processed from
      # PYTHONPATH
      touch buildpath/"homebrew/lib/python2.7/site-packages/google/__init__.py"
      chdir "python" do
        ENV.append_to_cflags "-I#{include}"
        ENV.append_to_cflags "-L#{lib}"
        args = Language::Python.setup_install_args libexec
        args << "--cpp_implementation"
        system "python", *args
      end
      site_packages = "lib/python2.7/site-packages"
      pth_contents = "import site; site.addsitedir('#{libexec/site_packages}')\n"
      (prefix/site_packages/"homebrew-protobuf.pth").write pth_contents
    end
  end

  def caveats; <<-EOS.undent
    Editor support and examples have been installed to:
      #{doc}
    EOS
  end

  test do
    testdata =
      <<-EOS.undent
        package test;
        message TestCase {
          required string name = 4;
        }
        message Test {
          repeated TestCase case = 1;
        }
        EOS
    (testpath/"test.proto").write(testdata)
    system bin/"protoc", "test.proto", "--cpp_out=."
    system "python", "-c", "import google.protobuf" if build.with? "python"
  end
end

__END__
diff --git a/src/google/protobuf/descriptor.h b/src/google/protobuf/descriptor.h
index 67afc77..504d5fe 100644
--- a/src/google/protobuf/descriptor.h
+++ b/src/google/protobuf/descriptor.h
@@ -59,6 +59,9 @@
 #include <vector>
 #include <google/protobuf/stubs/common.h>

+#ifdef TYPE_BOOL
+#undef TYPE_BOOL
+#endif

 namespace google {
 namespace protobuf {
