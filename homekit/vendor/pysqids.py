from sqids import Sqids

import sys

sqids = Sqids(alphabet="abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789")

#print(sqids.encode([28888]))
print(sqids.encode([long(sys.argv[1])]))
