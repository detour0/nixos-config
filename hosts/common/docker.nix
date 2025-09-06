{
    # After changing settings, Docker needs manual restart 'systemctl --user restart docker.service'
    virtualisation.docker.rootless = {
        enable = true;
        setSocketVariable = true;
        daemon.settings = {
            # DNS needs to be set, or requests from inside the container won't resolve
            # Docker usually reads the DNS from /etc/ersolv.conf, which Nixos keeps in the Nix Store
            dns = [
            "1.1.1.1"
            "9.9.9.9"
            ];
        };
    };
}