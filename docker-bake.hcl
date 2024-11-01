variable UBUNTU_VERSION {
  default = "focal-20240530"
}

group "default" {
  targets = ["emacs"]
}

target "emacs" {
  target     = "emacs"

  args = {
    UBUNTU_VERSION = UBUNTU_VERSION
    EMACS_VERSION = "29.4"
  }

  tags = [ "emacs:ubuntu-${UBUNTU_VERSION}" ]
}
