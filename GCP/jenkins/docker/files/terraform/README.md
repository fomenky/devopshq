# Provisioning HOWTO

1. Deploy:

```{bash}
dos2unix *
sudo cp ./* /usr/local/lib
echo -e "source /usr/local/lib/tflib.sh" >> /etc/bashrc
```

2. Plan:

```{bash}
source /usr/local/lib/tflib.sh

tflib_Plan.sh \
-r eu-west-1 \
-p vcp-dev \
-m /c/Users/lhdbo1/Projects/GetBusy/VirtualCabinetPortal/config/vcp-main-config/services/dev/backend/eu-west-1.tfvars.json \
-c /c/Users/lhdbo1/Projects/GetBusy/VirtualCabinetPortal/config/vcp-main-config/services/dev/terraform.tfvars.json \
-T /c/Users/lhdbo1/Projects/GetBusy/VirtualCabinetPortal/config/vcp-main-config/services/dev/tagging.tfvars.json
```

3. Provision:

```{bash}
source /usr/local/lib/tflib.sh

tflib_Provision.sh \
-r eu-west-1 \
-p vcp-dev
```

4. Destroy:

```{bash}
source /usr/local/lib/tflib.sh

tflib_Destroy.sh \
-r eu-west-1 \
-p vcp-dev \
-m /c/Users/lhdbo1/Projects/GetBusy/VirtualCabinetPortal/config/vcp-main-config/services/dev/backend/eu-west-1.tfvars.json \
-c /c/Users/lhdbo1/Projects/GetBusy/VirtualCabinetPortal/config/vcp-main-config/services/dev/terraform.tfvars.json \
-T /c/Users/lhdbo1/Projects/GetBusy/VirtualCabinetPortal/config/vcp-main-config/services/dev/tagging.tfvars.json
```
