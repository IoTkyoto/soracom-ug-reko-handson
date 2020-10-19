BUCKET_NAME="yamada-rekognition-collection-source"
PICTUER_NAME="Taro_Yamada.jpg"
COLLECTION_ID="yamada-authentication-collection"

aws rekognition search-faces-by-image --image '{"S3Object":{"Bucket":"'${BUCKET_NAME}'","Name":"'${PICTUER_NAME}'"}}' --collection-id "${COLLECTION_ID}"