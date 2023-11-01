locals {

    ## Tags
    tags = {
        Name = lower(var.name),
        sre-owner = "acheanyi.fomenky@thalesgroup.com",
        sre-environment = "sbn",
        sre-appstackcode = "apsnpd",
        sre-bl = "ibs",
        eng-projectcode = "000-00-0"
        sec-initiator = "terraform"
    }

}
