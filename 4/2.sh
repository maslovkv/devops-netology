#!/usr/bin/env bash
#добавим sha-bang
while ((1==1)) # Добавили закрывающую скобку для работы оператора сравнения
do
	curl https://localhost:4757
		if (($? != 0))
	then
		date >> curl.log
		sleep 1 # Установим задержку в 1 секунду. Уменьшим лог.
	else break  # Устраним основную ошибку. Добавим выход из цикла при достуности сервиса
	fi
done