node ('slave'){
    checkout scm

    stage('Build') {
        checkout scm
        sh 'pwd && cd src && /usr/local/bin/composer install'
        docker.build("cloudigital/nginx", "-f Dockerfile-nginx .")
        docker.build("cloudigital/Laravel_v670")
    }

    stage('Test') {
        docker.image('cloudigital/Laravel_v670').inside {
            sh 'php --version'
            sh 'cd /var/www/laravel5v5 && ./vendor/bin/phpunit --testsuite Unit'
        }
    }

    stage('Deploy') {
        sh 'cd src && /usr/local/bin/docker-compose down'
        sh 'cd src && /usr/local/bin/docker-compose up -d'
        sh 'sleep 10 && cd src && /usr/local/bin/docker-compose run web php artisan migrate'
    }

    stage ('Test Feature') {
        sh 'cd src && /usr/local/bin/docker-compose run web ./vendor/bin/phpunit --testsuite Feature'
    }
}
