﻿#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ДатаНачала = ТекущаяДата();
	СекундВМинуте = 60;
	ДатаОкончания = ДатаНачала + СекундВМинуте * СекундВМинуте;
	
	СформироватьТекстСообщения(ДатаНачала, ДатаОкончания);
	
	ПодключитьОбработчикОжидания("ОболочкаОбработчика", 30);
	
КонецПроцедуры

#КонецОбласти


#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура УстановитьБлокировку(Команда)
	СформироватьТекстСообщения(ДатаНачала, ДатаОкончания);
	УстановитьБлокировкуНаСервере(ДатаНачала, ДатаОкончания, ТекстСообщения);
	Закрыть();
	ЗавершитьРаботуСистемы(Ложь);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьБлокировкуНаСервере(Знач БлокировкаНачало, Знач БлокировкаКонец, Знач ТекстСообщения)
	
	Блокировка = Новый БлокировкаСеансов;
	Блокировка.Установлена = Истина;
	Блокировка.Начало = БлокировкаНачало;
	Блокировка.Конец   = БлокировкаКонец;
	Блокировка.КодРазрешения = "КодРазрешения";
	Блокировка.Сообщение = ТекстСообщения;
	
	УстановитьБлокировкуСеансов(Блокировка);

КонецПроцедуры // *УстановитьБлокировкуНаСервере

&НаКлиенте
Процедура ОболочкаОбработчика()
   ОтключитьОбработчикОжидания("ОболочкаОбработчика"); 	
   Если НЕ ЭтоИнтерактивныйРежим Тогда
	   УстановитьБлокировкуНаСервере(ДатаНачала, ДатаОкончания, ТекстСообщения);	
	   Закрыть();
	   ЗавершитьРаботуСистемы(Ложь);	
   КонецЕсли; 
КонецПроцедуры // *

&НаКлиенте
Процедура СформироватьТекстСообщения(ДатаНачала, ДатаОкончания)
	ТекстДатаНачала = Формат(ДатаНачала, "ДЛФ=T");
	ТекстДатаОкончания = Формат(ДатаОкончания, "ДЛФ=T");
	
	ТекстСообщения = "---->" + Символы.ПС 
	+ "----> ВНИМАНИЕ"+Символы.ПС
	+ "---->" + Символы.ПС
	+ "----> в %1 будет отключение всех пользователей !!!" + Символы.ПС
	+ "----> будут проводится технические работы до %2 !!" + Символы.ПС
	+ "----> Если кто-то хочет в это время работать звоните" + Символы.ПС
	+ "----> тел. 490-490 Максим."+Символы.ПС
	+ "---->";
	
	ТекстСообщения = СтрШаблон(ТекстСообщения, ТекстДатаНачала, ТекстДатаОкончания);
	
КонецПроцедуры // *СформироватьТекстСообщения


#КонецОбласти











