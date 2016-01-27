export NODENV_ROOT=<%= @install_dir %>
export PATH="$NODENV_ROOT/bin:$PATH"
eval "$(nodenv init -)"
