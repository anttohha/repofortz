pipeline{
    agent any
  
    options{
        buildDiscarder(logRotator(numToKeepStr: '1', daysToKeepStr: '1'))
        timestamps()
    }
    environment{
        registryCredential = 'dockerhub'
        registry = "anttohha/smallapp2"
        namespace1 = 'pre-production'
        namespace2 = 'production'
                
    }
    
    
    stages{
        
    stage ("Quality Dockerfile") {
    parallel {
       stage ("Dockerfile") {
         agent {
            docker {
               image 'hadolint/hadolint:latest-debian'
            }
         }
         steps {
            
            git branch: 'master', url: 'https://github.com/anttohha/repofortz.git'
            sh 'ls ' 
            sh 'hadolint TZ/Dockerfile --no-fail -f json | tee -a      ms1_docker_lint.txt'
         }
        post {
          always {
            archiveArtifacts 'ms1_docker_lint.txt'
          }
        }
     }
   }
        
    }
    
    stage('Cloning Git') {
      steps {
            cleanWs()
            
            git branch: 'main', url: 'https://github.com/anttohha/simple_app_for_tz.git'
            sh 'wget https://raw.githubusercontent.com/anttohha/repofortz/master/Dockerfile'
            sh 'ls'
            
      }
    }
    
    
    
    
    
    stage('Build Docker Image') {  
        steps{                     
	        script {
	            sh 'ls'
	            
                 dockerImage = docker.build registry + ":$BUILD_NUMBER"
            }              
        }           
    } 
    
    stage('Deploy our image') {
        steps{
            script {
                docker.withRegistry( '', registryCredential ) {
                dockerImage.push()
                }
            }
        }
    }
    
    stage('change deployment file and service') {
            steps {
               sh """
                cp /home/deployment.yaml /tmp
                sed -i -e 's/namespace: pre-production/namespace: production/g' /tmp/deployment.yaml
                sed -i -e 's/smallapp2:/smallapp2:$BUILD_NUMBER/g' /tmp/deployment.yaml
                cat /tmp/deployment.yaml >/home/deployment_prod.yaml
                
                cp /home/service.yaml /tmp
                sed -i -e 's/namespace: pre-production/namespace: production/g' /tmp/service.yaml
                cat /tmp/service.yaml >/home/service_prod.yaml
                
                cp /home/deployment.yaml /tmp
                sed -i -e 's/smallapp2:/smallapp2:$BUILD_NUMBER/g' /tmp/deployment.yaml
                cat /tmp/deployment.yaml >/home/deployment_preprod.yaml
               """
              
            }
        }
    
        
    stage('Deploy to pre-prodation'){
        steps{
             
             sh 'ls'
             sh 'kubectl --kubeconfig=/home/configk8s get ns'
             sh 'kubectl --kubeconfig=/home/configk8s apply -f /home/deployment_preprod.yaml'
             sh 'kubectl --kubeconfig=/home/configk8s apply -f /home/service.yaml'
             emailext body: 'deploy  from dockerhub to k8s , this is e-mail notificatuin', recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']], subject: 'Test'
             
        }
    }        
    
    stage('test deployment') {
            steps {
              sh '''
                #!/bin/bash 
                   echo 'Waiting 5 minutes for deployment to k8s'
                   sleep 300
                   ip1=$(kubectl --kubeconfig=/home/configk8s get svc -n pre-production | awk '{ print \$4}' | tail -n1)
                   echo $ip1
                   port1=$(kubectl --kubeconfig=/home/configk8s get svc -n pre-production | awk '{ print \$5}' | tail -n1 | cut -c 1-4)
                   echo $port1
                   curl -s $ip1:$port1
                   
                    
              '''
               
              
                
              
            }
        }
        
    stage('Deploy to prodation'){
        steps{
             
             sh 'ls'
             sh 'kubectl --kubeconfig=/home/configk8s get ns'
             sh 'kubectl --kubeconfig=/home/configk8s apply -f /home/deployment_prod.yaml'
             sh 'kubectl --kubeconfig=/home/configk8s apply -f /home/service_prod.yaml'
             emailext body: 'deploy  from dockerhub to k8s , this is e-mail notificatuin', recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']], subject: 'Test'
             
        }
    }       
    
   
    
    }
    
}
