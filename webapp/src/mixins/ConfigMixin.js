const searchFaces = {
  apiId: '',
  region: 'ap-northeast-1',
  stage: 'prod',
  resource: 'search',
  apiEndpoint: '',
  apiKey: '',
  threshold: 80,
};
const analysisFaces = {
  apiId: '',
  region: 'ap-northeast-1',
  stage: 'prod',
  resource: 'analyze',
  apiKey: '',
};
const analysisFacesUpload = {
  accessKeyID: '',
  secretAccessKey: '',
  iotCoreID: '',
  topicName: 'handson/analysisLogData',
};

export default {
  data () {
    return {
      config: {
        searchConfig: searchFaces,
        analysisConfig: analysisFaces,
        uploadConfig: analysisFacesUpload,
      }
    }
  }
}