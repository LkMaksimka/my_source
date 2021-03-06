﻿
#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВывестиВыраженияНаПечать(Команда)
    
    ТабДокумент = ВывестиВыраженияНаПечатьНаСервере();    
    КоллекцияПечатныхФорм = УправлениеПечатьюКлиент.НоваяКоллекцияПечатныхФорм("Макет");
    ПечатнаяФорма = УправлениеПечатьюКлиент.ОписаниеПечатнойФормы(КоллекцияПечатныхФорм, "Макет");
    ПечатнаяФорма.СинонимМакета = "Макет";
    ПечатнаяФорма.ТабличныйДокумент = ТабДокумент;
    ПечатнаяФорма.ИмяФайлаПечатнойФормы = "Макет";
    
    ОбластиОбъектов = Новый СписокЗначений;
    УправлениеПечатьюКлиент.ПечатьДокументов(КоллекцияПечатныхФорм, ОбластиОбъектов);

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Функция - Вывести выражения на печать на сервере
// 
// Возвращаемое значение:
//  ТабДок - ТабличныйДокумент
//
&НаСервере
Функция ВывестиВыраженияНаПечатьНаСервере()	

    ТабДок = Новый ТабличныйДокумент;
    ТабДок.КлючПараметровПечати = "ПараметрыПечати_ЗадачиНаСложениеИВычитаниеДо100";	

    Макет = РеквизитФормыВЗначение("Объект").ПолучитьМакет("Макет");
    ОбластьВсего = Макет.ПолучитьОбласть("ВсегоВыражений");
    Область = Макет.ПолучитьОбласть("ВыражениеСтрока|ВыражениеСтолбец");

    ВставлятьРазделительСтраниц = Ложь;

    МассивВыражений = СоздатьМассивВыражений();
    
    Если НужноПеремешать Тогда
    	МассивВыражений = ПеремешатьМассивВыражений(МассивВыражений);
    КонецЕсли; 
    
    ОбластьВсего.Параметры.ВсегоВыражений = МассивВыражений.Количество();
    ТабДок.Вывести(ОбластьВсего);
    
    МассивОбластей = Новый Массив;
    
    Для каждого ЭлементВыражения Из МассивВыражений Цикл
        МассивОбластей.Очистить();
               
        Если ВставлятьРазделительСтраниц Тогда
            ТабДок.ВывестиГоризонтальныйРазделительСтраниц();
            ВставлятьРазделительСтраниц = Ложь;
        КонецЕсли;	
        
        Область.Параметры.Выражение = ЭлементВыражения;
        МассивОбластей.Добавить(Область);
        
        Если ТабДок.ПроверитьПрисоединение(Область) Тогда
        	ТабДок.Присоединить(Область);
        Иначе
            ТабДок.Вывести(Область);
        КонецЕсли;
        
        Если НЕ ТабДок.ПроверитьВывод(МассивОбластей) Тогда
            ВставлятьРазделительСтраниц = Истина;	
        КонецЕсли;
        
    КонецЦикла; 

    Возврат ТабДок;
    
КонецФункции

// Функция - Создать массив выражений
// 
// Возвращаемое значение:
//   - Массив
//
&НаСервере
Функция СоздатьМассивВыражений()
    
    МассивЧисел1 = ПолучитьМассивЧисел(МаксимальнаяСумма);
    
    МассивВыражение = Новый Массив;
    
    Для каждого Элемент1 Из МассивЧисел1 Цикл
        
        Для каждого Элемент2 Из МассивЧисел1 Цикл
            ОтветСумма = Элемент1 + Элемент2;
            Часть1 = ?(Элемент1 < 10, "" + Элемент1 + " ", Строка(Элемент1));
            Если ОтветСумма <= МаксимальнаяСумма Тогда
                МассивВыражение.Добавить("" + Часть1 + " + " + Элемент2 );
            КонецЕсли;
            
            Если Элемент1 >= Элемент2 Тогда
                МассивВыражение.Добавить("" + Часть1 + " - " + Элемент2);
            КонецЕсли;
        КонецЦикла; 
        
    КонецЦикла;
    
    Возврат МассивВыражение;

КонецФункции

// Функция - Получить массив чисел 
//
// Параметры:
//      МаксимальнаяСумма - Число 
// 
// Возвращаемое значение:
//      - Массив
//
&НаСервере
Функция ПолучитьМассивЧисел(МаксимальнаяСумма)
    МассивЧисел = Новый Массив;
    Сч = 0;
    Пока Сч <= МаксимальнаяСумма Цикл
        МассивЧисел.Добавить(Сч);
    	Сч = Сч + 1;	
    КонецЦикла; 
    
    Возврат МассивЧисел;
КонецФункции

// Функция - Перемешать массив выражений
//
// Параметры:
//  МассивВыражений  - Массив 
// 
// Возвращаемое значение:
//   - Массив
//
&НаСервере
Функция ПеремешатьМассивВыражений(МассивВыражений)
    ВерхнийПредел = МассивВыражений.Количество() - 1;
    МассивПеремешанный = Новый Массив;            
    МассивИндексов = Новый Массив;
    ГСЧ = Новый ГенераторСлучайныхЧисел();
    
    Сч = 0;
    Пока Сч <= ВерхнийПредел Цикл
        
        НайденоЗначение = 0;
        
        Пока НайденоЗначение <> Неопределено Цикл
            Индекс = ГСЧ.СлучайноеЧисло(0, ВерхнийПредел);
            НайденоЗначение = МассивИндексов.Найти(Индекс);	
        КонецЦикла; 
        
        МассивИндексов.Добавить(Индекс);
        
        ВыбранныйЭлемент = МассивВыражений.Получить(Индекс);
        МассивПеремешанный.Добавить(ВыбранныйЭлемент);
        
        Сч = Сч + 1;
        
    КонецЦикла;
    
    Возврат  МассивПеремешанный; 
КонецФункции

#КонецОбласти



