locals {

    ## Tags
    tags = {
        Name = lower(var.name),
        sre-owner = "acf",
        sre-environment = "sandbox",
        sre-appstackcode = "xxxx",
        sre-bl = "xxx",
        eng-projectcode = "000-00-0"
        sec-initiator = "terraform"
    }

}
