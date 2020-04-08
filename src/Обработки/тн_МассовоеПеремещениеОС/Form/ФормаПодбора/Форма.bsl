﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
    Организация = Параметры.Организация;
    Период = Параметры.Дата;
    МножественныйВыбор = Параметры.МножественныйВыбор;
    Элементы.Таблица.МножественныйВыбор = МножественныйВыбор;
    Элементы.Таблица.РежимВыделения = ?(МножественныйВыбор, РежимВыделенияТаблицы.Множественный, РежимВыделенияТаблицы.Одиночный);    
    ИнициализироватьКомпоновкуДанных();
    
    ЗаполнитьПоОтборуНаСервере();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПодразделениеПриИзменении(Элемент)
    УстановитьОтбор("Подразделение", Подразделение);
КонецПроцедуры                      

&НаКлиенте
Процедура ОтборОСНастройкиОтборПриИзменении(Элемент)
    ЗаполнитьПоОтборуНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура МОЛПриИзменении(Элемент)
   УстановитьОтбор("МОЛ", МОЛ);
КонецПроцедуры

&НаКлиенте
Процедура ПодразделениеОчистка(Элемент, СтандартнаяОбработка)
   УдалитьОтбор("Подразделение");
КонецПроцедуры

&НаКлиенте
Процедура МОЛОчистка(Элемент, СтандартнаяОбработка)
   УдалитьОтбор("МОЛ");
КонецПроцедуры

#КонецОбласти


#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗаполнитьПоОтбору(Команда)
    ЗаполнитьПоОтборуНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура Выбрать(Команда)
    ВыбранныеЭлементы = Новый Массив;
    
    Если МножественныйВыбор Тогда
        Для каждого ИдентификаторСтроки Из Элементы.Таблица.ВыделенныеСтроки Цикл
            ДанныеСтроки = Элементы.Таблица.ДанныеСтроки(ИдентификаторСтроки);
            ВыбранныеЭлементы.Добавить(ДанныеСтроки);
        КонецЦикла;
    Иначе
        ВыбранныеЭлементы.Добавить(Элементы.Таблица.ТекущиеДанные);
    КонецЕсли;
    
    ОповеститьОВыборе(ВыбранныеЭлементы);
КонецПроцедуры

#КонецОбласти


#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ИнициализироватьКомпоновкуДанных()
    СхемаКомпоновкиДанных = Обработки.тн_МассовоеПеремещениеОС.ПолучитьМакет("Макет1");
	
	URLСхемы = ПоместитьВоВременноеХранилище(СхемаКомпоновкиДанных, Новый УникальныйИдентификатор());
	
	ИсточникНастроек = Новый ИсточникДоступныхНастроекКомпоновкиДанных(URLСхемы);
	
	ОтборОС.Инициализировать(ИсточникНастроек);
	
	ОтборОС.ЗагрузитьНастройки(СхемаКомпоновкиДанных.НастройкиПоУмолчанию);
	
КонецПроцедуры 

&НаСервере
Процедура ЗаполнитьПоОтборуНаСервере()
    ИменаДопРеквизтов = Новый Массив;
    ИменаДопРеквизтов.Добавить("ВидыОС_2e6b380ccc494574a87f54e7cb330928");
    ИменаДопРеквизтов.Добавить("ЛицензионныйУчасток_ed3b984d0a184072b163c43d06a80a42");
    ИменаДопРеквизтов.Добавить("НомерСкважины_683e4c84e0854f2a8e511c9962d59205");
    
    УстановитьЗначениеПараметраНастроек(ОтборОС.Настройки, "Имя", ИменаДопРеквизтов);
    УстановитьЗначениеПараметраНастроек(ОтборОС.Настройки, "ИмяВидОС", 
                                                           "ВидыОС_2e6b380ccc494574a87f54e7cb330928");
    УстановитьЗначениеПараметраНастроек(ОтборОС.Настройки, "ИмяЛицензионныйУчасток", 
                                                           "ЛицензионныйУчасток_ed3b984d0a184072b163c43d06a80a42");
    УстановитьЗначениеПараметраНастроек(ОтборОС.Настройки, "ИмяНомерСкважины", 
                                                           "НомерСкважины_683e4c84e0854f2a8e511c9962d59205");
    УстановитьЗначениеПараметраНастроек(ОтборОС.Настройки, "Организация", Организация);
    УстановитьЗначениеПараметраНастроек(ОтборОС.Настройки, "Период", Период);
    УстановитьЗначениеПараметраНастроек(ОтборОС.Настройки, "Состояние", Перечисления.СостоянияОС.ПринятоКУчету);
    
    СхемаКомпоновкиДанных = Обработки.тн_МассовоеПеремещениеОС.ПолучитьМакет("Макет1");
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки   = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, ОтборОС.ПолучитьНастройки(), , ,
                                                    Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
	
	ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновки);
	
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	Таблица.Загрузить(ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных));

КонецПроцедуры

Процедура УстановитьЗначениеПараметраНастроек(Настройки, ИмяПараметра, Значение)
	
	Параметр = Настройки.ПараметрыДанных.Элементы.Найти(ИмяПараметра);
	
	Если Параметр <> Неопределено Тогда
		Параметр.Значение = Значение;
		Параметр.Использование = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьОтбор(ИмяПолеОтбора, Значение)
    
    Настройки = ОтборОС.Настройки;
    
    Для каждого ЭлементОтбора Из Настройки.Отбор.Элементы Цикл
    	Если ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных(ИмяПолеОтбора) Тогда
        	 Настройки.Отбор.Элементы.Удалить(ЭлементОтбора);
        КонецЕсли;         
    КонецЦикла; 
    
    ЭлементОтбора = Настройки.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
    ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных(ИмяПолеОтбора);
    ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
    ЭлементОтбора.ПравоеЗначение = Значение;
    
    Настройки.ПараметрыВывода.УстановитьЗначениеПараметра("ВыводитьОтбор",
                                                            ТипВыводаТекстаКомпоновкиДанных.Выводить);
    
    ЗаполнитьПоОтборуНаСервере();
    
КонецПроцедуры

&НаКлиенте
Процедура УдалитьОтбор(ИмяПолеОтбора)
    
    Настройки = ОтборОС.Настройки;
    
    Для каждого ЭлементОтбора Из Настройки.Отбор.Элементы Цикл
    	Если ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных(ИмяПолеОтбора) Тогда
        	 Настройки.Отбор.Элементы.Удалить(ЭлементОтбора);
        КонецЕсли;         
    КонецЦикла; 
    
    Настройки.ПараметрыВывода.УстановитьЗначениеПараметра("ВыводитьОтбор",
                                                            ТипВыводаТекстаКомпоновкиДанных.Выводить);
    ЗаполнитьПоОтборуНаСервере();

КонецПроцедуры

#КонецОбласти
