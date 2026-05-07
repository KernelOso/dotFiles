if status is-interactive

     set fish_greeting ""
     
     # ===  Aliases ===
     
     # Ls
     alias ls='eza --icons --group-directories-first -1'
     
     # Rclone
     alias fastcopy="rclone copy -P --fast-list --create-empty-src-dirs --checkers=16 --transfers=16"
     
     # Cat
     alias cat="bat"
     
     # fastfetch
     alias fetch='/home/oso/.config/fastfetch/prettyFetch.sh'

     # Montar
     alias mnt="udisksctl mount -b"
 
     # Des-Montar
     alias umnt="udisksctl unmount -b"

     # Fonts
     alias fonts="fc-list : family"
     
     # Konekto Switches SSH
     alias swssh="ssh -oKexAlgorithms=+diffie-hellman-group14-sha1 -oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa"

     # === Autostart ===
     
     starship init fish | source
     
     fetch
     
end