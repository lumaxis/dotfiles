FROM ubuntu:latest

LABEL Name=dotfiles

RUN apt-get -y update && apt-get install -y --no-install-recommends make sudo

# Add user
RUN addgroup --gid 1000 user \
    && adduser --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --uid 1000 --disabled-password  --gid 1000 user
RUN echo "user ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers

USER user

WORKDIR /home/user/dotfiles
ADD . .

ENV CI=1

CMD bash -c './install.sh && ([[ -z $(zsh -c return) ]] || exit 1)'
