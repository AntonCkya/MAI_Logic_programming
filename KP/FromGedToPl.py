import sys


def translator(string):
    lower_letters = {
        u'а': u'a',
        u'б': u'b',
        u'в': u'v',
        u'г': u'g',
        u'д': u'd',
        u'е': u'e',
        u'ё': u'e',
        u'ж': u'zh',
        u'з': u'z',
        u'и': u'i',
        u'й': u'y',
        u'к': u'k',
        u'л': u'l',
        u'м': u'm',
        u'н': u'n',
        u'о': u'o',
        u'п': u'p',
        u'р': u'r',
        u'с': u's',
        u'т': u't',
        u'у': u'u',
        u'ф': u'f',
        u'х': u'kh',
        u'ц': u'ts',
        u'ч': u'ch',
        u'ш': u'sh',
        u'щ': u'sch',
        u'ъ': u'',
        u'ы': u'y',
        u'ь': u'',
        u'э': u'e',
        u'ю': u'yu',
        u'я': u'ya'
    }
    main_letters = {
        u'А': u'A',
        u'Б': u'B',
        u'В': u'V',
        u'Г': u'G',
        u'Д': u'D',
        u'Е': u'E',
        u'Ё': u'E',
        u'Ж': u'Zh',
        u'З': u'Z',
        u'И': u'I',
        u'Й': u'Y',
        u'К': u'K',
        u'Л': u'L',
        u'М': u'M',
        u'Н': u'N',
        u'О': u'O',
        u'П': u'P',
        u'Р': u'R',
        u'С': u'S',
        u'Т': u'T',
        u'У': u'U',
        u'Ф': u'F',
        u'Х': u'KH',
        u'Ц': u'Ts',
        u'Ч': u'Ch',
        u'Ш': u'Sh',
        u'Щ': u'Sch',
        u'Ъ': u'',
        u'Ы': u'Y',
        u'Ь': u'',
        u'Э': u'E',
        u'Ю': u'Yu',
        u'Я': u'Ya'
    }

    translit_string = ""

    for char in string:
        if char in lower_letters.keys():
            char = lower_letters[char]
        elif char in main_letters.keys():
            char = main_letters[char]
        translit_string += char

    return translit_string


if (len(sys.argv) != 2): # Если не указан файл .ged
    print("Usage: python3 " + sys.argv[0] + " GEDCOM-FILE")
else:
    # Выдёргиваем из файла все строки, содержащие SURN, GIVN, FAMS, FAMC, SEX
    res = []
    gedcomFile = open(sys.argv[1], "r", encoding='utf-8')
    for line in gedcomFile:
        for each in ["NAME", "FAMS", "FAMC", "SEX"]:
            if each in line:
                res.append(line)
    gedcomFile.close()

    for i in range(1, len(res)):
        listOfWords = res[i].split(' ') # Разбиваем строку на слова
        del listOfWords[0] # Удаляем число, обозначающее уровень
        res[i] = listOfWords
        for k in range(len(res[i])):
            res[i][k] = res[i][k].replace("\n", "") # Убираем символ перевода строки у слова


    for i in range(1, len(res)):
        if res[i][0] == "NAME":
            res[i][2] = res[i][2].replace("/", "")
            res[i][1] = res[i][1] + " " + res[i][2]
            del res[i][2]
            res[i][1] = translator(res[i][1])  # Переводим имена на английский язык

    k = 0
    for i in range(len(res) - 1, 0, -1): # Удаляем записи с пустыми или неизвестными именами
        if res[i][0] != "NAME":
            k = k + 1
        else:
            if (len(res[i][1]) == 0) or (res[i][1][0] == '?') or (res[i][1][-1] == '?') or (res[i][1][0:2] == "N "):
                while k >= 0:
                    del res[i]
                    k = k - 1
            k = 0


    families = []
    cur_name = ""
    cur_sex = ""
    for element in res:
        if element[0] == "NAME":
            cur_name = element[1]
            continue
        if element[0] == "SEX":
            cur_sex = element[1]
            continue
        isFound = False
        index = 0
        for familyIndex in range(len(families)):
            if families[familyIndex][0] == element[1]:
                isFound = True
                index = familyIndex
                break

        if isFound == True:
            if element[0] == "FAMS":
                families[index][1].append([cur_name, cur_sex])
            else:
                families[index][2].append([cur_name, cur_sex])
        else:
            families.append([])
            families[-1].append(element[1])
            families[-1].append([])
            families[-1].append([])
            if element[0] == "FAMS":
                # Означает, что он/она родитель
                families[-1][1].append([cur_name, cur_sex])
            else:
                # Означает, что он/она ребёнок
                families[-1][2].append([cur_name, cur_sex])

    outputFile = open("genealogicalTree.pl", "w")
    facts = []
    # Переводим строки в факты пролога
    for family in families:
        if len(family[2]) == 0:
            continue
        for child in family[2]:
            for parent in family[1]:
                if parent[1] == "M":
                    facts.append("father(\'" + parent[0] + "\', \'" + child[0] + "\').\n")
                else:
                    facts.append("mother(\'" + parent[0] + "\', \'" + child[0] + "\').\n")

    facts.sort(key=lambda st: st[0])
    for i in facts:
        outputFile.write(i)

    outputFile.close()

