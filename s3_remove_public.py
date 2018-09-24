#!/usr/bin/env python
#remove public read right for all keys within a directory

#usage: remove_public.py bucketName folderName

import sys
import boto

bucketname = sys.argv[1]
dirname = sys.argv[2]
s3 = boto.connect_s3()
bucket = s3.get_bucket(bucketname)

keys = bucket.list(dirname)

for k in keys:
    new_grants = []
    acl = k.get_acl()
    for g in acl.acl.grants:
        if g.uri != "http://acs.amazonaws.com/groups/global/AllUsers":
            new_grants.append(g)
    acl.acl.grants = new_grants
    k.set_acl(acl)
