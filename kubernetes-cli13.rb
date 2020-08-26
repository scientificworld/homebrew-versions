class KubernetesCli13 < Formula
  desc "Kubernetes command-line interface"
  homepage "http://kubernetes.io/"
  url "https://github.com/kubernetes/kubernetes/archive/v1.3.10.tar.gz"
  sha256 "7167e8c8e68d34596018103b55724f01d9b5e1f715c816c347a967cb438d6d18"

  depends_on "go" => :build

  conflicts_with "kubernetes-cli", :because => "Differing versions of the same formula"

  bottle do
    cellar :any_skip_relocation
    sha256 "362e73f18c3182c7fff76ed2311616587b8d93d7cf44e09b621847492edff435" => :sierra
    sha256 "d77c7e8b279fee7add1478bf27d91e77ddc43ce7abd06c702b98cad764b60948" => :el_capitan
    sha256 "16958fe90b5d3ead46e38243ed112176b1f42e03d309519cb86e786068296408" => :yosemite
  end

  def install
    if build.stable?
      system "make", "all", "WHAT=cmd/kubectl", "GOFLAGS=-v"
    else
      # avoids needing to vendor github.com/jteeuwen/go-bindata
      rm "./test/e2e/framework/gobindata_util.go"

      ENV.deparallelize { system "make", "generated_files" }
      system "make", "kubectl", "GOFLAGS=-v"
    end
    arch = MacOS.prefer_64_bit? ? "amd64" : "x86"
    bin.install "_output/local/bin/darwin/#{arch}/kubectl"

    output = Utils.popen_read("#{bin}/kubectl completion bash")
    (bash_completion/"kubectl").write output
  end

  test do
    output = shell_output("#{bin}/kubectl 2>&1")
    assert_match "kubectl controls the Kubernetes cluster manager.", output
  end
end
