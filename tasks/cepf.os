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

	МассивПутей = Новый Массив();

	Если Не ПустаяСтрока(ОдинКаталог) Тогда
		
		МассивПутей.Добавить(ОдинКаталог);
		
	Иначе
		
		МассивПутей.Добавить("./epf");
		МассивПутей.Добавить("./features");
		МассивПутей.Добавить("./vendor");
		МассивПутей.Добавить("./plugins");
		МассивПутей.Добавить("./lib/featurereader");
		МассивПутей.Добавить("./locales");
		
	КонецЕсли;

	Для каждого Элемент из МассивПутей Цикл
		ЗапуститьОбработку(Элемент);
	КонецЦикла;

КонецПроцедуры

Процедура ЗапуститьОбработку(Знач Путь)
	Перем ПодкаталогСборки;
	ПодкаталогСборки = ?(Бинарники1СХранятсяРядомСИсходникам, "", "build/"); //TODO для #29

	Файл = Новый Файл(Путь);
	Если Файл.ИмяБезРасширения = "epf" И Файл.ЭтоКаталог() Тогда 
		ШаблонЗапуска = СтрШаблон("oscript ./tools/runner.os compileepf ./epf ./%1", ПодкаталогСборки);
	Иначе
		ШаблонЗапуска = СтрШаблон("oscript ./tools/runner.os compileepf %1 ./%2%1", Путь, ПодкаталогСборки);
	КонецЕсли;
	ШаблонЗапуска = ШаблонЗапуска + " --ibname /F./build/ibservice";
	ИсполнитьКоманду(ШаблонЗапуска);
	
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