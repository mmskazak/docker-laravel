FROM php:8.4-fpm

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip

# Очистка кеша
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Установка PHP расширений
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Установка Redis
RUN pecl install redis && docker-php-ext-enable redis

# Установка Node.js и npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Установка Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Создание системного пользователя
RUN useradd -G www-data,root -u 1000 -d /home/dev dev && \
    mkdir -p /home/dev/.composer && \
    chown -R dev:dev /home/dev

# Настройка прав доступа
RUN mkdir -p /var/www && \
    chown -R dev:www-data /var/www && \
    chmod -R 775 /var/www

# Установка рабочей директории
WORKDIR /var/www

# Переключение на пользователя dev
USER dev

# Установка Laravel Installer для пользователя dev
RUN mkdir -p /home/dev/.composer && \
    composer global require laravel/installer

# Настройка PATH для пользователя dev
ENV PATH="/home/dev/.composer/vendor/bin:${PATH}"

# Возвращение к пользователю root (опционально)
# USER root