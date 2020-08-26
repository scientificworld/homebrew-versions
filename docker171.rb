class Docker171 < Formula
  desc "The Docker framework for containers"
  homepage "https://www.docker.com/"
  url "https://github.com/docker/docker.git",
      :tag => "v1.7.1",
      :revision => "786b29d4db80a6175e72b47a794ee044918ba734"

  bottle do
    cellar :any
    sha256 "d6bbc45a5e2123492f21927e99101f2ae0be9b1909941c9a58d2954ae515c6fe" => :yosemite
    sha256 "29fbd90ea38516a0df555e17e115bb18012cae479cdc4422a35c00b3b228c9c7" => :mavericks
    sha256 "add1e261d95be68a612449473cf16ea05c3e0fa1f6061ec91944293b18e3f557" => :mountain_lion
  end

  option "without-completions", "Disable bash/zsh completions"

  depends_on "go" => :build

  conflicts_with "docker", :because => "Differing version of the same formula"

  def install
    ENV["AUTO_GOPATH"] = "1"
    ENV["DOCKER_CLIENTONLY"] = "1"

    system "hack/make.sh", "dynbinary"
    bin.install "bundles/#{version}/dynbinary/docker-#{version}" => "docker"

    if build.with? "completions"
      bash_completion.install "contrib/completion/bash/docker"
      zsh_completion.install "contrib/completion/zsh/_docker"
    end
  end

  test do
    system "#{bin}/docker", "--version"
  end
end
