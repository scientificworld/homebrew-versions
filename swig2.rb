class Swig2 < Formula
  desc "Generate scripting interfaces to C/C++ code"
  homepage "http://www.swig.org/"
  url "https://downloads.sourceforge.net/project/swig/swig/swig-2.0.12/swig-2.0.12.tar.gz"
  sha256 "65e13f22a60cecd7279c59882ff8ebe1ffe34078e85c602821a541817a4317f7"

  bottle do
    sha256 "7b9a70bf790dec02a20db27083d4e951beaefb667b595d01e653d4c0208a1927" => :yosemite
    sha256 "adcb80642b175f0f522931d253c25c5eb16038eae88e7c0135e0ecacaccb5b7a" => :mavericks
    sha256 "db379c3fe24b5746772d1268f718541b5538074dec758749c201c29f08e484e0" => :mountain_lion
  end

  depends_on "pcre"

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      int add(int x, int y)
      {
        return x + y;
      }
    EOS
    (testpath/"test.i").write <<-EOS.undent
      %module test
      %inline %{
      extern int add(int x, int y);
      %}
    EOS
    (testpath/"run.rb").write <<-EOS.undent
      require "./test"
      puts Test.add(1, 1)
    EOS
    system "#{bin}/swig", "-ruby", "test.i"
    system ENV.cc, "-c", "test.c"
    system ENV.cc, "-c", "test_wrap.c", "-I/System/Library/Frameworks/Ruby.framework/Headers/"
    system ENV.cc, "-bundle", "-flat_namespace", "-undefined", "suppress", "test.o", "test_wrap.o", "-o", "test.bundle"
    assert_equal "2", shell_output("ruby run.rb").strip
  end
end
