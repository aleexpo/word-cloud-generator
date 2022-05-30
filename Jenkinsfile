pipeline {
    agent {
    label 'cloud'
    }
    stages {
        stage ('Pull sourcecode') {
            agent {
                dockerfile { 
                filename 'Dockerfile' args '--network host'
                }
            }
            steps {
                git 'https://github.com/wickett/word-cloud-generator.git'
                sh '''
                export GOPATH=$WORKSPACE/go
                export PATH="$PATH:$(go env GOPATH)/bin"
                go get github.com/tools/godep
                go get github.com/smartystreets/goconvey
                go get github.com/GeertJohan/go.rice/rice
                go get github.com/wickett/word-cloud-generator/wordyapi
                go get github.com/gorilla/mux
                sed -i "s/1.DEVELOPMENT/1.$BUILD_NUMBER/g" static/version
                GOOS=linux GOARCH=amd64 go build -o ./artifacts/word-cloud-generator -v
                gzip -f ./artifacts/word-cloud-generator
                '''
                nexusArtifactUploader artifacts: [[artifactId: 'word-cloud-generator', classifier: '', file: './artifacts/word-cloud-generator.gz', type: 'gz']], credentialsId: 'nexus_uploader', groupId: 'master', nexusUrl: 'localhost:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'word-cloud-build', version: '1.$BUILD_NUMBER'
            }
        }
        stage ('Tests'){
            agent {
                dockerfile {
                    filename 'alpine' 
                    dir 'src'
                    args '--network host'
                }
            }
            steps {
            sh '''
            apk add curl
            apk add jq
            apk add gcompat
            curl -X GET "http://localhost:8081/repository/word-cloud-build/master/word-cloud-generator/1.$BUILD_NUMBER/word-cloud-generator-1.$BUILD_NUMBER.gz" -o /opt/wordcloud/word-cloud-generator.gz
            ls /opt/wordcloud/
            gunzip -f /opt/wordcloud/word-cloud-generator.gz
            ls /opt/wordcloud/
            chmod +x /opt/wordcloud/word-cloud-generator
            ls /opt/wordcloud/
            /opt/wordcloud/word-cloud-generator& 
            res=`curl -s -H "Content-Type: application/json" -d '{"text":"ths is a really really really important thing this is"}' http://localhost:8888/version | jq '. | length'`
            if [ "1" != "$res" ]; then
            exit 99
            fi
            res=`curl -s -H "Content-Type: application/json" -d '{"text":"ths is a really really really important thing this is"}' http://localhost:8888/api | jq '. | length'`
            if [ "7" != "$res" ]; then
            exit 99
            fi
            '''
            }
        }
    }
}
