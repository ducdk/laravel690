node ('slave01'){ // Assign to node with labled "slave01" to run this task
    checkout scm

    // Define stages: Build => Unit Test => Deploy => Feature Test
    stage('Checkout & Build') {
        sh 'echo Building ${BRANCH_NAME}...'
        
        //1. Checkout scm, install depencies via composer then build ngxin + laravel container
        checkout scm
        
        // Install composer
        sh 'pwd && cd src && /usr/local/bin/composer install'
        
        //build nginx + php containers
        docker.build("cloudigital/nginx", "-f Dockerfile-nginx .")
        docker.build("cloudigital/laravel690", "-f Dockerfile-php .")
        
        //Notify build status to Jira
        jiraSendBuildInfo branch: 'LAR690-1', site: 'cloudigital.atlassian.net'
    }

    stage('=> Run Unit Test') {
        //2. Run Unit Test script inside via testsuite
        docker.image('cloudigital/laravel690').inside {
            sh 'php --version'
            //sh 'cd /var/www/laravel690 && ./vendor/bin/phpunit --testsuite Unit'
        }
    }

    stage('Deploy to DevelopEnv') {
        // 3. Delete old container that passed Unit Test and rebuild a new one
        sh 'cd src && /usr/local/bin/docker-compose down'        
        sh 'cd src && /usr/local/bin/docker-compose up -d'
        
        //DB migrate
        //sh 'sleep 10 && cd src && /usr/local/bin/docker-compose run web php artisan migrate --force'
        
        //Overwrite .env
        sh 'sleep 2 && cd src && cp .env.example .env'
        sh 'sleep 2 && cd src && php artisan key:generate'
        jiraSendDeploymentInfo environmentId: 'us-dev-1', environmentName: 'us-dev-1', environmentType: 'development', site: 'cloudigital.atlassian.net'
        
    }

    stage ('=> Run Feature Test') {
        // 4. A new deployed container comes and run Feature Test script inside via testsuite
        //sh 'sleep 5 && cd src && /usr/local/bin/docker-compose run web ./vendor/bin/phpunit --testsuite Feature'
    }
}
