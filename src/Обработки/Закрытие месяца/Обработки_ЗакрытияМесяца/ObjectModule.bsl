﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

Функция СведенияОВнешнейОбработке() Экспорт
	
	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке("2.2.2.1");
	Информация = НСтр("ru = 'Дополнительные обработки для закрытия месяца: 
						|Перезаполнение видов запасов, очистка регистра 'Резервы организации'.'");
	ПараметрыРегистрации.Информация = Информация;
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка();
	ПараметрыРегистрации.Версия = "1.0.2.2";
	ПараметрыРегистрации.БезопасныйРежим = Истина;
	
	Команда = ПараметрыРегистрации.Команды.Добавить();
	Команда.Представление = НСтр("ru = 'Настройка Парамеров'");
	Команда.Идентификатор = "Квартон_НастройкаПарамеров";
	Команда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
	Команда.ПоказыватьОповещение = Истина;
	
	Команда = ПараметрыРегистрации.Команды.Добавить();
	Команда.Представление = НСтр("ru = 'Фоновое перезаполнение Видов Запасов(будни)'");
	Команда.Идентификатор = "Квартон_ДополнительныеОбработкиДляЗакрытияМесяца_Будни";
	Команда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыВызовСерверногоМетода();
	Команда.ПоказыватьОповещение = Ложь;
	
	Команда = ПараметрыРегистрации.Команды.Добавить();
	Команда.Представление = НСтр("ru = 'Фоновое перезаполнение Видов Запасов(выходные)'");
	Команда.Идентификатор = "Квартон_ДополнительныеОбработкиДляЗакрытияМесяца_Выходные";
	Команда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыВызовСерверногоМетода();
	Команда.ПоказыватьОповещение = Ложь;
	
	Разрешение = РаботаВБезопасномРежиме.РазрешениеНаИспользованиеИнтернетРесурса("SMTP",  "mail.quarton.ru", "465");
	ПараметрыРегистрации.Разрешения.Добавить(Разрешение);
	
	Возврат ПараметрыРегистрации;
	
КонецФункции

Процедура ВыполнитьКоманду(ИдентификаторКоманды, ПараметрыКоманды) Экспорт
	
	ИмяСобытия = "Квартон.Квартон_ДополнительныеОбработкиДляЗакрытияМесяца";
	ДатаНачала = "Начало: " + Формат(ТекущаяДатаСеанса(), "ДЛФ=DDT");
	ДатаОкончания = "Окончание: " + Формат(ТекущаяДатаСеанса(), "ДЛФ=DDT");
	
	Период = Неопределено;
	ВидЦены = Справочники.ВидыЦен.ПустаяСсылка();
	
	ЗаписьЖурналаРегистрации(ИмяСобытия, УровеньЖурналаРегистрации.Предупреждение, , , ДатаНачала);
	Если ИдентификаторКоманды = "Квартон_ДополнительныеОбработкиДляЗакрытияМесяца_Будни"
		 ИЛИ ИдентификаторКоманды = "Квартон_ДополнительныеОбработкиДляЗакрытияМесяца_Выходные" Тогда
		ХранилищеНастроек = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(
							ПараметрыКоманды.ДополнительнаяОбработкаСсылка,
							"ХранилищеНастроек");
							
		Настройки = ХранилищеНастроек.Получить();
		
		Если ТипЗнч(Настройки) = Тип("Структура") Тогда
			Период = Настройки.Период;
			ВидЦены = Настройки.ВидЦены;
		КонецЕсли;
		
		Если ВидЦены <> Справочники.ВидыЦен.ПустаяСсылка() И Период <> Неопределено Тогда
			МассивОшибок = Новый Массив;
			МассивОшибок.Добавить("Начало: " + ТекущаяДатаСеанса());
			ВыгрузитьДанныеНаСервер(Период, ВидЦены, МассивОшибок);
			Неделя = КонецНедели(КонецДня(Период.ДатаОкончания) + 1);
			НовыйПериод = Новый СтандартныйПериод(Период.ДатаОкончания, Неделя);
			СохранитьПараметрыАвтоПерезаполненияВидовЗапасов(НовыйПериод, ВидЦены, ПараметрыКоманды);
			МассивОшибок.Добавить("Окончание: " + ТекущаяДатаСеанса());
			ОтправитьПоПочтеРезультат(МассивОшибок);
		КонецЕсли; 
		
	КонецЕсли;
	ЗаписьЖурналаРегистрации(ИмяСобытия, УровеньЖурналаРегистрации.Предупреждение, , , ДатаОкончания);
	
КонецПроцедуры

Процедура СохранитьПараметрыАвтоПерезаполненияВидовЗапасов(Период, ВидЦены, Параметры) Экспорт
	СохраняемоеЗначение = Новый Структура;
	СохраняемоеЗначение.Вставить("Период", Период);
	СохраняемоеЗначение.Вставить("ВидЦены", ВидЦены);
	
	ДополнительнаяОбработкаОбъект = Параметры.ДополнительнаяОбработкаСсылка.ПолучитьОбъект(); 
	ДополнительнаяОбработкаОбъект.ХранилищеНастроек = Новый ХранилищеЗначения(СохраняемоеЗначение); 
	ДополнительнаяОбработкаОбъект.Записать(); 
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

#Область ПерезаполнениеВидовЗапасов

Процедура ПерезаполнениеВидовЗапасов(СтруктураПараметров, МассивОшибок) Экспорт
	
	Период = СтруктураПараметров.Период;
	
	МассивДокуменов = ПолучитьСписокДокументов();
	
	ТекстЗапроса = "";
	Сч = 0;
	
	Если НЕ СтруктураПараметров.ПроверкаКоличестваДокументов Тогда
		// Очистка Резервов Организации
		ОчисткаРегистровТоварыРезервыОрганизации(Период.ДатаНачала);
	КонецЕсли; 
	
	Для каждого ЭлементМассива Из МассивДокуменов Цикл    
		Сч = Сч + 1;
		Если ЭлементМассива = "ВводОстатков" Тогда
			Условие  = "И Документ.ТипОперации = Значение(Перечисление.ТипыОперацийВводаОстатков.ОстаткиСобственныхТоваров)";
		Иначе
			Условие  = "";
		КонецЕсли;
		ТекстЗапроса = ТекстЗапроса +
		"ВЫБРАТЬ
		|	Документ.Ссылка КАК Ссылка,
		|	Документ.МоментВремени КАК МоментВремени
		|  ПОМЕСТИТЬ ВременнаяТаблица" + Сч + "
		|ИЗ
		|	Документ." + ЭлементМассива + " КАК Документ
		|ГДЕ
		|	Документ.Проведен = ИСТИНА
		|	И Документ.Дата МЕЖДУ &ДатаНач И &ДатаОкон
		|   " + Условие + "
		|;
		|////////////////////////////////////////////////////////////////////////////////
		|";
	КонецЦикла; 
	
	Вт = 0;
	Пока Вт < Сч Цикл
		Вт = Вт + 1;
		ТекстЗапроса = ТекстЗапроса +
		
		"ВЫБРАТЬ
		|	ВременнаяТаблица.Ссылка КАК Ссылка,
		|	ВременнаяТаблица.МоментВремени КАК МоментВремени
		|ИЗ
		|	ВременнаяТаблица" + Вт + " КАК ВременнаяТаблица
		|";
		
		Если Вт < Сч Тогда
			ТекстЗапроса = ТекстЗапроса +
			"
			|ОБЪЕДИНИТЬ ВСЕ
			|
			|";
		КонецЕсли; 
		
	КонецЦикла; 
	
	  ТекстЗапроса = ТекстЗапроса +
			"
			|УПОРЯДОЧИТЬ ПО
			|МоментВремени
			|";
	
	Запрос = Новый Запрос;
	Запрос.Текст =  ТекстЗапроса;
	Запрос.УстановитьПараметр("ДатаНач", Период.ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкон", КонецДня(Период.ДатаОкончания));
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	КоличествоДокументов = ВыборкаДетальныеЗаписи.Количество();
	МассивОшибок.Добавить(КоличествоДокументов);
	
	Если СтруктураПараметров.ПроверкаКоличестваДокументов Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	Сч = 1;
	ОсталосьДокументов = КоличествоДокументов;
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		ПерезаполнитьВидыЗапасовДокумента(ВыборкаДетальныеЗаписи, ОсталосьДокументов, МассивОшибок);
		
		Если Сч = СтруктураПараметров.Пачка И СтруктураПараметров.Пауза > 0 Тогда
			ОбщегоНазначенияБТС.Пауза(СтруктураПараметров.Пауза);	
		КонецЕсли; 
		
		Сч = Сч + 1;
		ОсталосьДокументов = ОсталосьДокументов - 1;
	КонецЦикла;
	

КонецПроцедуры

Процедура ПерезаполнениеВидовЗапасовПоВыбраннойАналитики(Период, СписокАналитикНоменклатуры, МассивОшибок) Экспорт
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТоварыОрганизаций.Регистратор КАК Ссылка,
		|	ТоварыОрганизаций.АналитикаУчетаНоменклатуры КАК АналитикаУчетаНоменклатуры,
		|	ТоварыОрганизаций.Регистратор.МоментВремени КАК РегистраторМоментВремени
		|ИЗ
		|	РегистрНакопления.ТоварыОрганизаций КАК ТоварыОрганизаций
		|ГДЕ
		|	ТоварыОрганизаций.АналитикаУчетаНоменклатуры В(&АналитикаУчетаНоменклатуры)
		|	И ТоварыОрганизаций.Период >= &ДатаНач
		|
		|ОБЪЕДИНИТЬ
		|
		|ВЫБРАТЬ
		|	РезервыТоваровОрганизаций.Регистратор,
		|	РезервыТоваровОрганизаций.АналитикаУчетаНоменклатуры,
		|	РезервыТоваровОрганизаций.Регистратор.МоментВремени
		|ИЗ
		|	РегистрНакопления.РезервыТоваровОрганизаций КАК РезервыТоваровОрганизаций
		|ГДЕ
		|	РезервыТоваровОрганизаций.АналитикаУчетаНоменклатуры В(&АналитикаУчетаНоменклатуры)
		|	И РезервыТоваровОрганизаций.Период >= &ДатаНач
		|
		|УПОРЯДОЧИТЬ ПО
		|	РегистраторМоментВремени";
	
	Запрос.УстановитьПараметр("АналитикаУчетаНоменклатуры", СписокАналитикНоменклатуры);
	Запрос.УстановитьПараметр("ДатаНач", Период.ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкон", КонецДня(Период.ДатаОкончания) + 1);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	// Очистка Резервов Организации
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Регистратор = ВыборкаДетальныеЗаписи.Ссылка;
		АналитикаУчетаНоменклатуры = ВыборкаДетальныеЗаписи.АналитикаУчетаНоменклатуры;
		
		УдалитьДанныеПоАналитикеИзРегистра("РезервыТоваровОрганизаций", АналитикаУчетаНоменклатуры, Регистратор);
		УдалитьДанныеПоАналитикеИзРегистра("ТоварыОрганизаций", АналитикаУчетаНоменклатуры, Регистратор);
	КонецЦикла;

							 
	ВыборкаДетальныеЗаписи.Сбросить();
	
	
	КоличествоДокументов = ВыборкаДетальныеЗаписи.Количество();
	Сч = 1;
	ОсталосьДокументов = КоличествоДокументов;
	МассивОшибок.Добавить(КоличествоДокументов);
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		ПерезаполнитьВидыЗапасовДокумента(ВыборкаДетальныеЗаписи, ОсталосьДокументов, МассивОшибок);
		
		Сч = Сч + 1;
		ОсталосьДокументов = ОсталосьДокументов - 1;
	КонецЦикла;
	
	ОтправитьПоПочтеРезультат(МассивОшибок);
КонецПроцедуры

Процедура ОбновитьНастройкуПередачиТоваров(СпособПередачиТоваров, ВидЦены) Экспорт 
	
	Если СпособПередачиТоваров = Перечисления.СпособыПередачиТоваров.Продажа Тогда
		ЗаполнитьНастройкуПередачиТоваровКакПродажа(ВидЦены);
	Иначе
		ЗаполнитьНастройкуПередачиТоваровКакНеПередается(ВидЦены);
	КонецЕсли; 
	
КонецПроцедуры

#КонецОбласти //ПерезаполнениеВидовЗапасов


#Область ОчисткаРезервовОрганизации
// Параметры: Период - Дата
//			  ПоНеПроведеннымДокументам - булево
// Описание: удалем данные из регистра
// Возвращаемое значение: Строка
Процедура ОчиститьВесьРегистрРезервовОрганизации(Дата, ПоНеПроведеннымДокументам) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	Запрос = Новый Запрос;
	
	ТекстЗапросов = 
	     "ВЫБРАТЬ РАЗЛИЧНЫЕ
        |	РезервыТоваровОрганизаций.Регистратор КАК Регистратор
        |ИЗ
        |	РегистрНакопления.РезервыТоваровОрганизаций КАК РезервыТоваровОрганизаций
        |ГДЕ
        |	&УсловиеГДЕ
		|УПОРЯДОЧИТЬ ПО
        |	РезервыТоваровОрганизаций.Регистратор.Дата";
	
	Если Дата <> Дата("00010101") Тогда
		УсловиеГДЕ = "РезервыТоваровОрганизаций.Период >= &Период";
		Запрос.УстановитьПараметр("Период", Дата);
	КонецЕсли; 
	
	Если ПоНеПроведеннымДокументам Тогда
		УсловиеГДЕ = "РезервыТоваровОрганизаций.Регистратор.Проведен = ЛОЖЬ";
	КонецЕсли; 
	
	ТекстЗапросов = СтрЗаменить(ТекстЗапросов, "&УсловиеГДЕ", УсловиеГДЕ);
	Запрос.Текст = ТекстЗапросов;

    РезультатЗапроса = Запрос.Выполнить(); 
    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();  
    Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		ОчиститьРегистрНакопленияПоРегистратору("РезервыТоваровОрганизаций", ВыборкаДетальныеЗаписи.Регистратор);
	КонецЦикла;
	
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры

#КонецОбласти //ОчисткаРезервовОрганизации


#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ПерезаполнениеВидовЗапасов

Процедура ВыгрузитьДанныеНаСервер(Период, ВидЦены, МассивОшибок) 

	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("ПроверкаКоличестваДокументов", Ложь);
	СтруктураПараметров.Вставить("Период", Период);
	СтруктураПараметров.Вставить("Пачка", 0);
	СтруктураПараметров.Вставить("Пауза", 0);
	ПерезаполнениеВидовЗапасов(СтруктураПараметров, МассивОшибок);
	
КонецПроцедуры // *ВыгрузитьДанныеНаСервер

Процедура ПерезаполнитьВидыЗапасовДокумента(Знач ВыборкаДетальныеЗаписи, Знач ОсталосьДокументов, МассивОшибок)
	
	
	Док = ВыборкаДетальныеЗаписи.Ссылка.ПолучитьОбъект();
	
	Если Док.Метаданные().Реквизиты.Найти("ВидыЗапасовУказаныВручную")  <>  Неопределено Тогда
		Док.ВидыЗапасовУказаныВручную = Ложь;
	КонецЕсли; 
	
	Док.ДополнительныеСвойства.Вставить("ПерезаполнитьВидыЗапасов", Истина);
	// далее в ВерсионированиеОбъектовСобытия.ЗаписатьВерсиюДокумента()
	// указываем что если кв_ПерезаполнитьВидыЗапасов пропускаем версионирование
	Док.ДополнительныеСвойства.Вставить("кв_ПропуститьЗаписьВерсииОбъекта", Истина);
	
	ОчиститьВидыЗапасов(Док);
  
	// Очистим ГТД, так как были случаи что сначала вели учет по ГДТ,
	// а потом передумали, а данные в документах остались.
	ЕстьРеквизитНомераГТД = ЕстьРеквизитТабЧастиДокумента("НомерГТД", Док.Метаданные(), "Товары");
	Если ЕстьРеквизитНомераГТД Тогда
		ОчисткаНомеровГТД(Док);
 	КонецЕсли; 
	
	
	Попытка
		// Док.Заполнить(Неопределено); не надо так делать в этой базе  
		Док.Записать(РежимЗаписиДокумента.Проведение);
	Исключение
		СсылкаНаДокумент = ПолучитьНавигационнуюСсылку(Док.Ссылка);
		ТекстОшибки = "---" + Символы.ПС 
							+ ТекущаяДатаСеанса() 
							+ Символы.ПС 
							+ ОписаниеОшибки() 
							+ Символы.ПС 
							+ СсылкаНаДокумент;
		МассивОшибок.Добавить(ТекстОшибки);
	КонецПопытки;
	
	Комментарий = "Зафиксирован документ: " + Док.Дата + "; Осталось документов: " + ОсталосьДокументов;
	УровеньЖурнала = УровеньЖурналаРегистрации.Примечание;
	ЗаписьЖурналаРегистрации("Квартон.Перезаполнение Видов Запасов", УровеньЖурнала, , , Комментарий);

КонецПроцедуры

Процедура ОчисткаНомеровГТД(Док)
	
	Для каждого СтрокаТЧ Из Док.Товары Цикл
		
		ВестиУчетПоГТД = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаТЧ.Номенклатура, "ВестиУчетПоГТД");
		ВестиУчетПоГТД = ?(ВестиУчетПоГТД = Неопределено, Ложь, ВестиУчетПоГТД);
		Если Не ВестиУчетПоГТД Тогда
			СтрокаТЧ.НомерГТД = Справочники.НомераГТД.ПустаяСсылка();
		КонецЕсли;
		
	КонецЦикла;

КонецПроцедуры

Процедура ОчиститьВидыЗапасов(Док)
	
	Если ТипЗнч(Док) = Тип("ДокументОбъект.КорректировкаРеализации") Тогда
		Док.ВидыЗапасовКорректировкаВыручки.Очистить();
		Док.ВидыЗапасовОприходование.Очистить();
		Док.ВидыЗапасовСписание.Очистить();
	ИначеЕсли ТипЗнч(Док) = Тип("ДокументОбъект.СборкаТоваров") Тогда 
		Док.ВидыЗапасовОприходование.Очистить();
		Док.ВидыЗапасовСписание.Очистить();
	ИначеЕсли ТипЗнч(Док) = Тип("ДокументОбъект.ВводОстатков") 
		ИЛИ ТипЗнч(Док) = Тип("ДокументОбъект.кв_ЗаявкаНаСервис") Тогда 
		Для каждого СтрокаТЧ Из Док.Товары Цикл
			СтрокаТЧ.ВидЗапасов = Справочники.ВидыЗапасов.ПустаяСсылка();
		КонецЦикла; 
	Иначе
		Док.ВидыЗапасов.Очистить();
	КонецЕсли;

КонецПроцедуры

#КонецОбласти //ПерезаполнениеВидовЗапасов

Функция ПолучитьСписокДокументов()
	МассивДокументов = Новый Массив;
	МассивДокументов.Добавить("ВводОстатков");
	МассивДокументов.Добавить("ВнутреннееПотреблениеТоваров");
	МассивДокументов.Добавить("ВозвратТоваровМеждуОрганизациями");
	МассивДокументов.Добавить("ВозвратТоваровОтКлиента");
	МассивДокументов.Добавить("ВозвратТоваровПоставщику");
	МассивДокументов.Добавить("ВыкупВозвратнойТарыКлиентом");
	МассивДокументов.Добавить("КорректировкаВидаДеятельностиНДС");
	МассивДокументов.Добавить("КорректировкаНазначенияТоваров");
	МассивДокументов.Добавить("КорректировкаНалогообложенияНДСПартийТоваров");
	МассивДокументов.Добавить("КорректировкаОбособленногоУчетаЗапасов");
	МассивДокументов.Добавить("КорректировкаПриобретения");
	МассивДокументов.Добавить("КорректировкаРеализации");
	МассивДокументов.Добавить("МаркировкаТоваровГИСМ");
	МассивДокументов.Добавить("ОтчетКомиссионера");
	МассивДокументов.Добавить("ОтчетКомиссионераОСписании");
	МассивДокументов.Добавить("ОтчетКомитенту");
	МассивДокументов.Добавить("ОтчетКомитентуОСписании");
	МассивДокументов.Добавить("ОтчетОРозничныхПродажах");
	МассивДокументов.Добавить("ОтчетПоКомиссииМеждуОрганизациями");
	МассивДокументов.Добавить("ОтчетПоКомиссииМеждуОрганизациямиОСписании");
	МассивДокументов.Добавить("ПередачаТоваровМеждуОрганизациями");
	МассивДокументов.Добавить("ПеремаркировкаТоваровГИСМ");
	МассивДокументов.Добавить("ПеремещениеТоваров");
	МассивДокументов.Добавить("ПересортицаТоваров");
	МассивДокументов.Добавить("ПорчаТоваров");
	МассивДокументов.Добавить("ПоступлениеТоваровНаСклад");   
	МассивДокументов.Добавить("ПриобретениеТоваровУслуг");
	МассивДокументов.Добавить("ПрочееОприходованиеТоваров");
	МассивДокументов.Добавить("РеализацияТоваровУслуг");
	МассивДокументов.Добавить("СборкаТоваров");
	МассивДокументов.Добавить("СписаниеНедостачТоваров");
	МассивДокументов.Добавить("кв_ВыдачаТоваровССервиса");
	МассивДокументов.Добавить("кв_ЗаявкаНаСервис");
	
	Возврат МассивДокументов; 
КонецФункции

#Область НастройкаПередачиТоваровМеждуОрганизациями

Процедура ЗаполнитьНастройкуПередачиТоваровКакПродажа(ВидЦены)
	СписокОрганизаций = ПолучитьСписокОрганизаций();
	
	Для каждого ЭлементВладелец Из СписокОрганизаций Цикл
		
		Для каждого ЭлементПродавец Из СписокОрганизаций  Цикл
			Если ЭлементПродавец = ЭлементВладелец Тогда
				Продолжить;
			КонецЕсли; 
			ТекЗапись = РегистрыСведений.НастройкаПередачиТоваровМеждуОрганизациями.СоздатьМенеджерЗаписи();
			ТекЗапись.ОрганизацияВладелец = ЭлементВладелец;
			ТекЗапись.ОрганизацияПродавец = ЭлементПродавец;
			ТекЗапись.ТипЗапасов = Перечисления.ТипыЗапасов.Товар;
			ТекЗапись.Прочитать();
			Если ТекЗапись.Выбран() Тогда
				ТекЗапись.СпособПередачиТоваров = Перечисления.СпособыПередачиТоваров.Продажа;
				ТекЗапись.ВидЦены = ВидЦены;
				ТекЗапись.Записать();
			КонецЕсли; 
		КонецЦикла; 
		
	КонецЦикла; 
КонецПроцедуры

Процедура ЗаполнитьНастройкуПередачиТоваровКакНеПередается(ВидЦены)
	СписокОрганизаций = ПолучитьСписокОрганизаций();
	
	Для каждого ЭлементВладелец Из СписокОрганизаций Цикл
		
		Для каждого ЭлементПродавец Из СписокОрганизаций  Цикл
			Если ЭлементПродавец = ЭлементВладелец Тогда
				Продолжить;
			КонецЕсли; 
			ОбновитьНастройкиПередачиТоваровМеждуОрганизациями(ВидЦены, ЭлементВладелец, ЭлементПродавец);
		КонецЦикла; 
		
	КонецЦикла; 
	
КонецПроцедуры

Процедура ОбновитьНастройкиПередачиТоваровМеждуОрганизациями(Знач ВидЦены, Знач ЭлементВладелец, Знач ЭлементПродавец)
	
	КомпТехнологии	= Справочники.Организации.НайтиПоРеквизиту("ИНН", "2130173287");
	БайковаЭИ		= Справочники.Организации.НайтиПоРеквизиту("ИНН", "212904696468");
	СОФТКОМПЬЮТЕР	= Справочники.Организации.НайтиПоРеквизиту("ИНН", "2130187177");
	КВАРТОНК		= Справочники.Организации.НайтиПоРеквизиту("ИНН", "1658122666");
	ПАРТНЕРНН		= Справочники.Организации.НайтиПоРеквизиту("ИНН", "5263113606");

	
	ТекЗапись = РегистрыСведений.НастройкаПередачиТоваровМеждуОрганизациями.СоздатьМенеджерЗаписи();
	ТекЗапись.ОрганизацияВладелец = ЭлементВладелец;
	ТекЗапись.ОрганизацияПродавец = ЭлементПродавец;
	ТекЗапись.ТипЗапасов = Перечисления.ТипыЗапасов.Товар;
	ТекЗапись.Прочитать();
	
	Если ТекЗапись.Выбран() Тогда
		
		Если БайковаЭИ = ЭлементПродавец Тогда
			ТекЗапись.СпособПередачиТоваров = Перечисления.СпособыПередачиТоваров.Продажа;
			ТекЗапись.ВидЦены = ВидЦены;
			
		ИначеЕсли КомпТехнологии = ЭлементВладелец 
			И (СОФТКОМПЬЮТЕР = ЭлементПродавец ИЛИ КВАРТОНК = ЭлементПродавец 
			ИЛИ ПАРТНЕРНН = ЭлементПродавец) Тогда
			
			ТекЗапись.СпособПередачиТоваров = Перечисления.СпособыПередачиТоваров.Продажа;
			ТекЗапись.ВидЦены = ВидЦены;
			
		Иначе
			ТекЗапись.СпособПередачиТоваров = Перечисления.СпособыПередачиТоваров.НеПередается;
			ТекЗапись.ВидЦены = Справочники.ВидыЦен.ПустаяСсылка();
		КонецЕсли; 
		
		ТекЗапись.Записать();
	КонецЕсли;

КонецПроцедуры


// Возвращаемое значение: 
// 	Массив - со списком организаций, не помеченных на удаление
Функция ПолучитьСписокОрганизаций()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Организации.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Организации КАК Организации
		|ГДЕ
		|	НЕ Организации.ПометкаУдаления";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	МассивОрганизаций = Новый Массив;
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		МассивОрганизаций.Добавить(ВыборкаДетальныеЗаписи.Ссылка);
	КонецЦикла;
	
	Возврат МассивОрганизаций;

КонецФункции

#КонецОбласти //НастройкаПередачиТоваровМеждуОрганизациями


Процедура ОтправитьПоПочтеРезультат(МассивРезультатов)
	МассивПолучателей = Новый Массив;
	МассивПолучателей.Добавить("mmaksimov@quarton.ru");
	УчетнаяЗапись = Справочники.УчетныеЗаписиЭлектроннойПочты.СистемнаяУчетнаяЗаписьЭлектроннойПочты;
	
	Если НЕ УчетнаяЗапись.Пустая() Тогда
		Профиль = РаботаСПочтовымиСообщениямиСлужебный.ИнтернетПочтовыйПрофиль(УчетнаяЗапись);
	Иначе
		Возврат;
	КонецЕсли;
	
	Почта = Новый ИнтернетПочта;
	Попытка
		Почта.Подключиться(Профиль);
	Исключение
		Возврат;
	КонецПопытки;
	
	Сообщение = Новый ИнтернетПочтовоеСообщение;
	Сообщение.ИмяОтправителя = УчетнаяЗапись.Пользователь;
	Сообщение.Отправитель = УчетнаяЗапись.АдресЭлектроннойПочты;
	Сообщение.Тема = "#Результат Перезаполнения Видов запасов.";
	
	ПочтовыеАдреса = Сообщение.Получатели;
	Для каждого ЭлементаМасс Из МассивПолучателей Цикл
		ПочтовыйАдрес = ПочтовыеАдреса.Добавить();
		ПочтовыйАдрес.Адрес = ЭлементаМасс;	
	КонецЦикла; 
	
	ТекстПисьма = "";
	Для каждого Элемента Из МассивРезультатов Цикл
		ТекстПисьма = ТекстПисьма + Символы.ПС + Элемента;
	КонецЦикла; 
	
	ИнтернетТекстПочтовогоСообщения = Сообщение.Тексты.Добавить();
	ИнтернетТекстПочтовогоСообщения.Текст = ТекстПисьма; 
	ИнтернетТекстПочтовогоСообщения.ТипТекста = ТипТекстаПочтовогоСообщения.ПростойТекст;
	
	Попытка
		// Пытаемся послать письмо
		Почта.Послать(Сообщение);
	Исключение
		Возврат;
	КонецПопытки;
	// отключение
	Почта.Отключиться();   
	
КонецПроцедуры

Функция ЕстьРеквизитТабЧастиДокумента(ИмяРеквизита, МетаданныеДокумента, ИмяТабЧасти) 

    ТабЧасть = МетаданныеДокумента.ТабличныеЧасти.Найти(ИмяТабЧасти);

    Если ТабЧасть = Неопределено Тогда// Нет такой таб. части в документе 
        Возврат Ложь;

    Иначе
        Возврат НЕ (ТабЧасть.Реквизиты.Найти(ИмяРеквизита) = Неопределено);

    КонецЕсли;

КонецФункции

// ++ *ММГ 10.01.2020 Номер задачи: ;   
// Описание: очищаем регистры чтобы систма не видела остатки будующего :), для выравнивания по ГТД.
// Параметры: ДатаОт - Дата от которой нужно очищать регистр.
Процедура ОчисткаРегистровТоварыРезервыОрганизации(ДатаОт)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТоварыОрганизаций.Регистратор КАК Ссылка,
		|	ТоварыОрганизаций.АналитикаУчетаНоменклатуры КАК АналитикаУчетаНоменклатуры,
		|	ТоварыОрганизаций.Регистратор.МоментВремени КАК РегистраторМоментВремени
		|ИЗ
		|	РегистрНакопления.ТоварыОрганизаций КАК ТоварыОрганизаций
		|ГДЕ
		|	ТоварыОрганизаций.Период >= &ДатаНач
		|
		|ОБЪЕДИНИТЬ
		|
		|ВЫБРАТЬ
		|	РезервыТоваровОрганизаций.Регистратор,
		|	РезервыТоваровОрганизаций.АналитикаУчетаНоменклатуры,
		|	РезервыТоваровОрганизаций.Регистратор.МоментВремени
		|ИЗ
		|	РегистрНакопления.РезервыТоваровОрганизаций КАК РезервыТоваровОрганизаций
		|ГДЕ
		|	РезервыТоваровОрганизаций.Период >= &ДатаНач
		|
		|УПОРЯДОЧИТЬ ПО
		|	РегистраторМоментВремени";
	
	Запрос.УстановитьПараметр("ДатаНач", ДатаОт);
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		ОчиститьРегистрНакопленияПоРегистратору("РезервыТоваровОрганизаций", ВыборкаДетальныеЗаписи.Ссылка);
		ОчиститьРегистрНакопленияПоРегистратору("ТоварыОрганизаций", ВыборкаДетальныеЗаписи.Ссылка);
	КонецЦикла;

КонецПроцедуры // -- *ММГ 10.01.2020

Процедура УдалитьДанныеПоАналитикеИзРегистра(ИмяРегистраНакопления, АналитикаУчетаНоменклатуры, Регистратор)
	УдаляемыеЗаписи = Новый Массив;
	
	Набор = РегистрыНакопления[ИмяРегистраНакопления].СоздатьНаборЗаписей();
	Набор.Отбор.Регистратор.Значение = Регистратор;
	Набор.Прочитать();
	
	Для Каждого ЗаписьНабора Из Набор Цикл
		Если ЗаписьНабора.АналитикаУчетаНоменклатуры = АналитикаУчетаНоменклатуры Тогда
			УдаляемыеЗаписи.Добавить(ЗаписьНабора);
		КонецЕсли;	
	КонецЦикла; 
	
	Для Каждого УдаляемаяЗапись Из УдаляемыеЗаписи Цикл
		Набор.ОбменДанными.Загрузка = Истина;
		Набор.Удалить(УдаляемаяЗапись);
	КонецЦикла;  	
	
	Набор.Записать();
КонецПроцедуры

// Описание: удаление записей регистра без проверок.
// Параметры: ИмяРегистра - Строка
// 			  Регистратор - Ссылка на документ регистратор
Процедура ОчиститьРегистрНакопленияПоРегистратору(ИмяРегистра, Регистратор)
	Набор = РегистрыНакопления[ИмяРегистра].СоздатьНаборЗаписей();
	Набор.Отбор.Регистратор.Значение = Регистратор;
	Набор.ОбменДанными.Загрузка = Истина;
	Набор.Записать();
КонецПроцедуры // -- *ММГ 29.01.2020


#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли