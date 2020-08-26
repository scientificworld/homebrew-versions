class Unison240 < Formula
  desc "Unison file synchronizer"
  homepage "http://www.cis.upenn.edu/~bcpierce/unison/"
  url "http://www.seas.upenn.edu/~bcpierce/unison/download/releases/unison-2.40.128/unison-2.40.128.tar.gz"
  sha256 "5a1ea828786b9602f2a42c2167c9e7643aba2c1e20066be7ce46de4779a5ca54"

  bottle do
    cellar :any_skip_relocation
    revision 1
    sha256 "dfe253294f54d90a2fb3e5f8b2316b11726ad76cc9c7e8965dfcaee551814f00" => :el_capitan
    sha256 "6519f3a415677e6daf0072253f150693463312d6b7d68801c294aa68d9c09672" => :yosemite
    sha256 "6ff17e0dbdde5bf54fa66296224c842783e88d0ce08fa0226d23b76431f25740" => :mavericks
  end

  depends_on "ocaml" => :build

  def install
    ENV.deparallelize
    ENV.delete "CFLAGS" # ocamlopt reads CFLAGS but doesn't understand common options
    ENV.delete "NAME" # https://github.com/Homebrew/homebrew/issues/28642
    system "make", "./mkProjectInfo"
    system "make", "UISTYLE=text"
    bin.install "unison"
  end

  test do
    system bin/"unison", "-version"
  end
end
