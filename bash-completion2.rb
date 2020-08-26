class BashCompletion2 < Formula
  desc "Programmable completion for Bash 4.0+"
  homepage "https://github.com/scop/bash-completion"
  url "https://github.com/scop/bash-completion/releases/download/2.4/bash-completion-2.4.tar.xz"
  sha256 "c0f76b5202fec9ef8ffba82f5605025ca003f27cfd7a85115f838ba5136890f6"
  head "https://github.com/scop/bash-completion.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "3d4d824313eef450b32440cbbe22b47b37486dea42534792cb5fa09f4f8357e8" => :el_capitan
    sha256 "756fd7260c13dc9f71f15e833289e15d13421eca826d11a6397462cedff71a6f" => :yosemite
    sha256 "756fd7260c13dc9f71f15e833289e15d13421eca826d11a6397462cedff71a6f" => :mavericks
  end

  conflicts_with "bash-completion"

  def install
    inreplace "bash_completion", "readlink -f", "readlink"

    system "./configure", "--prefix=#{prefix}", "--sysconfdir=#{etc}"
    ENV.deparallelize
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    Add the following to your ~/.bash_profile:
      if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
        . $(brew --prefix)/share/bash-completion/bash_completion
      fi
    EOS
  end

  test do
    system "test", "-f", "#{share}/bash-completion/bash_completion"
  end
end
