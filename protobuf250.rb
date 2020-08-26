class Protobuf250 < Formula
  homepage "https://github.com/google/protobuf"
  url "https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.bz2"
  sha256 "13bfc5ae543cf3aa180ac2485c0bc89495e3ae711fc6fab4f8ffe90dfb4bb677"

  bottle do
    cellar :any
    sha256 "ee9fea383fceb77512ea1ff1e5d49f615e099df5971a4c69a9d4d83840b24e56" => :yosemite
    sha256 "1b4272b801679a59d05050af402a55a17b759409884e455f212a056ff485e653" => :mavericks
    sha256 "5ee898191f6e0453427f837ba7db8e2bd39294ea270efd28927d52f05bc4f59c" => :mountain_lion
  end

  option :universal
  option :cxx11

  # this will double the build time approximately if enabled
  option "with-check", "Run build-time check"

  depends_on python => :optional

  conflicts_with "protobuf", :because => "conflicts with protobuf in main repository."

  def install
    # Don't build in debug mode. See:
    # https://github.com/Homebrew/homebrew/issues/9279
    ENV.prepend "CXXFLAGS", "-DNDEBUG"
    ENV.universal_binary if build.universal?
    ENV.cxx11 if build.cxx11?

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-zlib"
    system "make"
    system "make", "check" if build.with?("check") || build.bottle?
    system "make", "install"

    # Install editor support and examples
    doc.install "editors", "examples"

    if build.with? "python"
      chdir "python" do
        ENV["PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION"] = "cpp"
        ENV.append_to_cflags "-I#{include}"
        ENV.append_to_cflags "-L#{lib}"
        args = Language::Python.setup_install_args libexec
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
    (testpath/"test.proto").write <<-EOS.undent
      package test;
      message TestCase {
        required string name = 4;
      }
      message Test {
        repeated TestCase case = 1;
      }
    EOS
    system bin/"protoc", "test.proto", "--cpp_out=."
    system "python", "-c", "import google.protobuf" if build.with? "python"
  end
end
