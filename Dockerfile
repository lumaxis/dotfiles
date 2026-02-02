FROM ubuntu:latest

LABEL Name=dotfiles

RUN apt-get -y update && apt-get install -y --no-install-recommends make sudo adduser

# Add user (use different GID to avoid conflicts with existing ubuntu user)
RUN groupadd -g 1001 user \
    && useradd -m -u 1001 -g 1001 -c "First Last,RoomNumber,WorkPhone,HomePhone" -s /bin/bash user
RUN echo "user ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers

USER user

WORKDIR /home/user/dotfiles
ADD . .

ENV CI=1

CMD ["bash", "-c", "./install.sh && if [[ -n $(zsh -c return) ]]; then exit 1; fi"]
