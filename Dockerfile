FROM makerdao/dapphub-tools

WORKDIR /home/maker/dss-proxy-actions
COPY . .

RUN sudo chown -R maker:maker /home/maker/dss-proxy-actions

CMD /bin/bash -c "export PATH=/home/maker/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin && dapp --use solc:0.5.12 test"
