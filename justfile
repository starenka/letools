tools := "alarm brightness monitor player rae_wotd repls startup volume weather"
bin_dir := env_var('HOME') / "bin"

default:
    @just --list

# symlink every tool into ~/bin (idempotent)
install:
    mkdir -p {{bin_dir}}
    for f in {{tools}}; do \
        ln -sf {{justfile_directory()}}/$f {{bin_dir}}/$f; \
        echo "linked {{bin_dir}}/$f -> {{justfile_directory()}}/$f"; \
    done
