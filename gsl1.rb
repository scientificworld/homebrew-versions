class Gsl1 < Formula
  desc "Numerical library for C and C++"
  homepage "https://www.gnu.org/software/gsl/"
  url "https://ftpmirror.gnu.org/gsl/gsl-1.16.tar.gz"
  mirror "https://ftp.gnu.org/gnu/gsl/gsl-1.16.tar.gz"
  sha256 "73bc2f51b90d2a780e6d266d43e487b3dbd78945dd0b04b14ca5980fe28d2f53"

  bottle do
    cellar :any
    sha256 "c90aae66eb711e5dfaf23a2519d8a0d557af0c5ebfee23da24f30696d7ce2bbb" => :el_capitan
    sha256 "5027ba24fc613bc80500956df563feb55887bc6b68763acb1ad8006a7c71693c" => :yosemite
    sha256 "26726db85cdcb16073aa735091d70e3a0ae4c93f4919d58e164721df54cc8471" => :mavericks
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make" # A GNU tool which doesn't support just make install! Shameful!
    system "make", "install"
  end

  test do
    system bin/"gsl-randist", "0", "20", "cauchy", "30"
  end
end
