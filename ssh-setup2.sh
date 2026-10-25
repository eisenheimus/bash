#!/bin/bash
#
# Скрипт настройки пользователя ansible и OpenSSH Server на Ubuntu

set -e  # Остановить выполнение при любой ошибке

# Проверка, что скрипт запущен от root
if [ "$EUID" -ne 0 ]; then
    echo "Ошибка: скрипт нужно запускать от root (или через sudo)"
    exit 1
fi

echo "=== [1/6] Создание пользователя ansible ==="
if id "ansible" &>/dev/null; then
    echo "Пользователь 'ansible' уже существует, пропускаем создание."
else
    useradd -m -s /bin/bash ansible
    echo "Пользователь 'ansible' создан."
fi

echo "=== [2/6] Добавление пользователя ansible в группу sudo ==="
usermod -aG sudo ansible
echo "Пользователь 'ansible' добавлен в группу sudo."

echo "=== [3/6] Установка пароля для пользователя ansible ==="
# Запрашиваем пароль с консоли (ввод скрыт), с подтверждением
while true; do
    read -r -s -p "Введите пароль для пользователя ansible: " PASSWORD
    echo
    read -r -s -p "Повторите пароль: " PASSWORD_CONFIRM
    echo

    if [ -z "$PASSWORD" ]; then
        echo "Пароль не может быть пустым. Попробуйте снова."
        continue
    fi

    if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
        echo "Пароли не совпадают. Попробуйте снова."
        continue
    fi

    break
done

# Устанавливаем пароль, не передавая его через аргументы командной строки
echo "ansible:${PASSWORD}" | chpasswd
unset PASSWORD PASSWORD_CONFIRM
echo "Пароль установлен."

echo "=== [4/6] Обновление списка пакетов и установка openssh-server ==="
apt-get update -y
apt-get install -y openssh-server

echo "=== [5/6] Включение автозапуска ssh сервиса ==="
systemctl enable ssh
echo "Сервис ssh включён в автозапуск."

echo "=== [6/6] Перезапуск сервиса ssh ==="
systemctl restart ssh
echo "Сервис ssh перезапущен."

echo ""
echo "=== Готово! Статус сервиса ssh: ==="
systemctl status ssh --no-pager
