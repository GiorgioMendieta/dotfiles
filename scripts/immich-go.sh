immich-go \
  upload \
  from-google-photos \
  --server=http://192.168.1.100:2283 \
  --api-key=nQ5RvVvFEsZPMnPkfv4rIbSEX0StkWjr9z6CtgRsNCE \
  --concurrent-tasks=4 \
  --manage-raw-jpeg=StackCoverRaw \
  --manage-heic-jpeg=StackCoverJPG \
  --manage-burst=Stack \
  ~/Downloads/takeout-*.zip
