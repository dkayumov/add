#Использовать logos
#Использовать 1commands

Перем ВозможныеКоманды;
Перем Лог;
Перем ЭтоWindows;
Перем Бинарники1СХранятсяРядомСИсходникам; //TODO для #29

Процедура ИнициализацияОкружения()

	СистемнаяИнформация = Новый СистемнаяИнформация;
	ЭтоWindows = Найти(ВРег(СистемнаяИнформация.ВерсияОС), "WINDOWS") > 0;

	Лог = Логирование.ПолучитьЛог("oscript.app.vanessa-init");
	Лог.УстановитьРаскладку(ЭтотОбъект);
	
	ОдинКаталог = "";
	Если ЗначениеЗаполнено(АргументыКоманднойСтроки) Тогда
		ИндексПоследнегоЭлемента = АргументыКоманднойСтроки.ВГраница();
		ОдинКаталог = Строка(АргументыКоманднойСтроки[ИндексПоследнегоЭлемента]);
	КонецЕсли;

	УстановитьПеременнуюСреды("RUNNER_IBNAME", "/F./build/ibservice");
	// УстановитьПеременнуюСреды("RUNNER_IBCONNECTION", "/F./build/ibservice");

	ПодкаталогСборки = ?(Бинарники1СХранятсяРядомСИсходникам, "", "build/"); //TODO для #29

	МассивПутей = Новый Массив();

	Если Не ПустаяСтрока(ОдинКаталог) Тогда

		Если ОдинКаталог = "./epf" Или ОдинКаталог = "bddRunner.epf" 
			ИЛИ ОдинКаталог = СтрШаблон("./%1bddRunner.epf", ПодкаталогСборки) Тогда
			
			МассивПутей.Добавить("./epf");
		Иначе
			МассивПутей.Добавить(ОдинКаталог);
		КонецЕсли;

	Иначе
		
		МассивПутей.Добавить("./epf");
		МассивПутей.Добавить("./lib/featurereader");
		МассивПутей.Добавить("./features");
		МассивПутей.Добавить("./vendor");
		МассивПутей.Добавить("./plugins");
		
	КонецЕсли;

	Для каждого Элемент из МассивПутей Цикл
		Если Элемент = "./epf" Тогда
			ШаблонЗапуска = СтрШаблон("oscript ./tools/runner.os decompileepf ./%3%2 %1 --ibname /F./build/ibservice", 
				Элемент, "bddRunner.epf", ПодкаталогСборки);
		Иначе
			ШаблонЗапуска = СтрШаблон("oscript ./tools/runner.os decompileepf ./%2%1 %1 --ibname /F./build/ibservice", 
				Элемент, ПодкаталогСборки);
		КонецЕсли;
		ИсполнитьКоманду(ШаблонЗапуска);
	КонецЦикла;

	УдалитьИзИзмененийГита_БинарныеФайлыТолстыхФорм_ЕслиВМодулеФормыНеБылоИзменений();
	
КонецПроцедуры

Процедура УдалитьИзИзмененийГита_БинарныеФайлыТолстыхФорм_ЕслиВМодулеФормыНеБылоИзменений()
	СтрокаЗапуска = "git diff --name-status HEAD";
	ЖурналИзмененийГит = ИсполнитьКоманду(СтрокаЗапуска);

	МассивИмен = Новый Массив;
	МассивСтрокЖурнала = СтрРазделить(ЖурналИзмененийГит, Символы.ПС);
	Для Каждого СтрокаЖурнала Из МассивСтрокЖурнала Цикл
		Лог.Отладка("	<%1>", СтрокаЖурнала);
		СтрокаЖурнала = СокрЛ(СтрокаЖурнала);
		СимволИзменений = Лев(СтрокаЖурнала, 1);
		Если СимволИзменений = "M" Тогда
			ИмяФайла = СокрЛП(Сред(СтрокаЖурнала, 2));
			// ИмяФайла = СтрЗаменить(ИмяФайла, Символ(0), "");
			МассивИмен.Добавить(ИмяФайла);
			Лог.Отладка("		В журнале git найдено имя файла <%1>", ИмяФайла);
		КонецЕсли;
	КонецЦикла;

	Для каждого Элемент из МассивИмен Цикл
		Если Прав(Элемент, 8) = "Form.bin" Тогда
			ЧастьПути = Лев(Элемент, СтрДлина(Элемент)-8);
			Лог.Информация(ЧастьПути);
			ПутьМодуляФормы = ЧастьПути + "Form/Module.bsl";
			Если СтрНайти(ЖурналИзмененийГит, ПутьМодуляФормы) = 0 Тогда
				ИсполнитьКоманду("git checkout -- " + Элемент);
				Приостановить(2000);
				
				ИсполнитьКоманду("git checkout -- " + ЧастьПути);
				Приостановить(2000);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Функция ИсполнитьКоманду(Знач СтрокаВыполнения)
	
	Команда = Новый Команда;
	Команда.ПоказыватьВыводНемедленно(Истина);

	Команда.УстановитьПравильныйКодВозврата(0);

	Лог.Информация(СтрокаВыполнения);
	Команда.УстановитьСтрокуЗапуска(СтрокаВыполнения);
	Команда.Исполнить();

	Возврат Команда.ПолучитьВывод();
	
КонецФункции

Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт

	Возврат СтрШаблон("%1: %2 - %3", ТекущаяДата(), УровниЛога.НаименованиеУровня(Уровень), Сообщение);

КонецФункции

Бинарники1СХранятсяРядомСИсходникам = Ложь; //TODO для #29
ИнициализацияОкружения();