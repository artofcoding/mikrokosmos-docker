#!/bin/sh
#
# Copyright (C) 2019 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
sed -i'' -e 's#ZSH_THEME=.*#ZSH_THEME="powerlevel9k/powerlevel9k"#' ~/.zshrc
cat >>~/.zshrc <<EOF
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(time context dir vcs rbenv status root_indicator)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
EOF

exit 0
