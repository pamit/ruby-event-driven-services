threads_count = Integer(ENV.fetch("WEB_CONCURRENCY", 2))

workers Integer(ENV.fetch("WEB_WORKERS", 1))
threads threads_count, threads_count
port        ENV.fetch("PORT", 4567)
environment ENV.fetch("RACK_ENV", "development")

preload_app!
