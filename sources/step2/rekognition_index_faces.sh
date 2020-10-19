BUCKET_NAME="yamada-rekognition-collection-source"
PICTUER_NAME="Taro_Yamada.jpg"
COLLECTION_ID="yamada-authentication-collection"
EXTERNAL_IMAGE_ID="Taro_Yamada" 

aws rekognition index-faces --image '{"S3Object":{"Bucket":"'${BUCKET_NAME}'","Name":"'${PICTUER_NAME}'"}}' --collection-id "${COLLECTION_ID}" --max-faces 1 --quality-filter "AUTO"  --detection-attributes "ALL" --external-image-id "${EXTERNAL_IMAGE_ID}"
