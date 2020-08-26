class Libxml278 < Formula
  desc "Libxml2 is the XML C parser and toolkit"
  homepage "http://xmlsoft.org"
  url "http://xmlsoft.org/sources/libxml2-2.7.8.tar.gz"
  mirror "ftp://xmlsoft.org/libxml2/libxml2-2.7.8.tar.gz"
  sha256 "cda23bc9ebd26474ca8f3d67e7d1c4a1f1e7106364b690d822e009fdc3c417ec"

  bottle do
    sha256 "e2afe51f87e12b0bd5f5a06803f397a0a2658ee04999a6b50569a0acd3afb4f1" => :yosemite
    sha256 "3e8e3fe83ad886f416ccd475052f68f3bfcf30be8f4bb7a3e67d8e76eadac783" => :mavericks
    sha256 "1ae08e74cf7b71d5c139db86a81f83098a4438546c70e030d3dc4552d49a404b" => :mountain_lion
  end

  depends_on python => :optional

  keg_only :provided_by_osx

  option :universal

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--without-python"
    system "make"
    ENV.deparallelize
    system "make", "install"

    if build.with? "python"
      cd "python" do
        # We need to insert our include dir first
        inreplace "setup.py", "includes_dir = [", "includes_dir = ['#{include}', '#{MacOS.sdk_path}/usr/include',"
        system "python", "setup.py", "install", "--prefix=#{prefix}"
      end
    end
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <libxml/tree.h>

      int main()
      {
        xmlDocPtr doc = xmlNewDoc(BAD_CAST "1.0");
        xmlNodePtr root_node = xmlNewNode(NULL, BAD_CAST "root");
        xmlDocSetRootElement(doc, root_node);
        xmlFreeDoc(doc);
        return 0;
      }
    EOS
    args = `#{bin}/xml2-config --cflags --libs`.split
    args += %w[test.c -o test]
    system ENV.cc, *args
    system "./test"
  end
end
