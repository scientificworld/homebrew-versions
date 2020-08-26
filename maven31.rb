class Maven31 < Formula
  desc "Java-based project management"
  homepage "https://maven.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=maven/maven-3/3.1.1/binaries/apache-maven-3.1.1-bin.tar.gz"
  sha256 "077ed466455991d5abb4748a1d022e2d2a54dc4d557c723ecbacdc857c61d51b"

  depends_on :java

  conflicts_with "maven", :because => "Differing versions of same formula"

  def install
    # Remove windows files
    rm_f Dir["bin/*.bat"]

    # Fix the permissions on the global settings file.
    chmod 0644, "conf/settings.xml"

    prefix.install_metafiles
    libexec.install Dir["*"]
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end
end
