class Rebar3 < Formula
  desc "Erlang build tool"
  homepage "https://github.com/erlang/rebar3"
  url "https://github.com/erlang/rebar3/archive/3.3.2.tar.gz"
  sha256 "ccbc27355727090b1fdde7497ab2485c3509e2fd14b48a93276b285b5760d092"

  head "https://github.com/rebar/rebar3.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "309100a2b267bad724992dbae9714d0ee4eb530b974809f13e0375f49320d5ca" => :sierra
    sha256 "8c195c6cc0b45e114d6fb84b36644687650a2d63d748b802821a133094e16ccc" => :el_capitan
    sha256 "3a9d5f37f96d3ca413bf5a63703f6aeb7bca41cc6f0cca03d7b3cec74e61593e" => :yosemite
  end

  depends_on "erlang"

  def install
    system "./bootstrap"
    bin.install "rebar3"

    bash_completion.install "priv/shell-completion/bash/rebar3"
    zsh_completion.install "priv/shell-completion/zsh/_rebar3" => "_rebar3"
    fish_completion.install "priv/shell-completion/fish/rebar3.fish"
  end

  test do
    system bin/"rebar3", "--version"
  end
end
