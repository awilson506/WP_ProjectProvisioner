@servers(['prod' => '{{SERVER}}'])


@task('deploy', ['on' => 'production'])
	cd {{DOCROOT}}
	php artisan down
	git pull origin master
	composer update --no-dev
	php artisan migrate
	php artisan up
@endtask