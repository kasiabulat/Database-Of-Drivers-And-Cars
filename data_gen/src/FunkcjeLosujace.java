import java.text.Normalizer;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Random;
import java.util.regex.Pattern;

/**
 * Created by Michal Stobierski on 2016-06-03.
 */

public class FunkcjeLosujace {

    static Random rNum = new Random();

    static long generujPesel(int plec, String data_urodzenia){
        // Generowanie prawdziwego PESELu
        long suma_kontrolna = 0;
        long pesel = 0;
        pesel = 0;

        long temp = Integer.parseInt(data_urodzenia.substring(2, 4));  // rok urodzenia
        pesel += temp;
        suma_kontrolna += ((temp/10) + (temp%10)*3);

        temp = Integer.parseInt(data_urodzenia.substring(5, 7));   // miesiac urodzenia
        pesel *= 100; pesel += temp;
        suma_kontrolna += ((temp/10)*7 + (temp%10)*9);

        temp = Integer.parseInt(data_urodzenia.substring(8, 10));   // dzien urodzenia
        pesel *= 100; pesel += temp;
        suma_kontrolna += ((temp/10) + (temp%10)*3);

        temp = rNum.nextInt(100);  // byle co
        pesel *= 100; pesel += temp;
        suma_kontrolna += ((temp/10)*7 + (temp%10)*9);

        temp = rNum.nextInt(99) + 1;  // znowu
        if(plec == 0 && temp%2 == 1) temp--;    // plec jest 10 cyfra peselu, zalezy od parzystosci
        else if(plec == 1 && temp%2 == 0) temp--;
        pesel *= 100; pesel += temp;
        suma_kontrolna += ((temp/10)*1 + (temp%10)*3);

        pesel *= 10; pesel += ((10 - (suma_kontrolna%10))%10);

        return pesel;
        // uff, koniec PESELU
    }

    static List<String> generuj_imie_nazwisko(int plec)
    {
        List<String> res = new ArrayList<>();
        if(plec == 0)
        {
            res.add(Dane.imionaDamskie.get(rNum.nextInt(Dane.imionaDamskie.size())));
            res.add(Dane.nazwiskaDamskie.get(rNum.nextInt(Dane.nazwiskaDamskie.size())));
        }
        else
        {
            res.add(Dane.imionaMeskie.get(rNum.nextInt(Dane.imionaMeskie.size())));
            res.add(Dane.nazwiskaMeskie.get(rNum.nextInt(Dane.nazwiskaMeskie.size())));
        }
        return res;
    }

    static String generuj_mail(){
        String email = "";
        for (int i = 0, fin = rNum.nextInt(9)+3; i < fin; ++i) {
            email += (char)(rNum.nextInt(26) + 'a');
        }
        email += Dane.domenyMailowe.get(rNum.nextInt(Dane.domenyMailowe.size()));
        return email;
    }

    public static String deAccent(String str) {
        String nfdNormalizedString = Normalizer.normalize(str, Normalizer.Form.NFD);
        Pattern pattern = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        nfdNormalizedString = nfdNormalizedString.replaceAll("ł", "l");
        return pattern.matcher(nfdNormalizedString).replaceAll("");
    }

    static String generuj_mail(String imie, String nazwisko){
        String email = "";
        email += nazwisko.toLowerCase(Locale.ENGLISH);
        email += ".";
        email += imie.toLowerCase(Locale.ENGLISH);
        email += Dane.domenyMailowe.get(rNum.nextInt(Dane.domenyMailowe.size()));

        email = deAccent(email);    // magia ze stackoverflow q 1008802
        return email;
    }

    static String generuj_numer_telefonu(){
        String res = "";
        res += (char)(rNum.nextInt(4) + '5');   // cyfra 5-8
        for (int i = 1; i < 9; ++i) {
            res += (char)(rNum.nextInt(10) + '0');  // dowolna cyfra
        }
        return res;
    }

    static String generuj_adres()
    {
        String adres = "";
        adres = Dane.adresy.get(rNum.nextInt(Dane.adresy.size()));
        adres += " ";
        for (int i = 0; i < rNum.nextInt(2)+1; ++i){
            adres += (char)(rNum.nextInt(10) + '0');    // dowolna cyfra
        }
        adres += "/";
        adres += (char)(rNum.nextInt(9) + '1');
        for (int i = 0; i < rNum.nextInt(3); ++i){
            adres += (char)(rNum.nextInt(10) + '0');    // dowolna cyfra
        }
        adres += ", ";
        for (int i = 0; i < 2; ++i){
            adres += (char)(rNum.nextInt(10) + '0');    // dowolna cyfra
        }
        adres += "-";
        for (int i = 0; i < 3; ++i){
            adres += (char)(rNum.nextInt(10) + '0');    // dowolna cyfra
        }
        adres += " ";
        adres += Dane.nazwyMiast.get(rNum.nextInt(Dane.nazwyMiast.size()));
        return adres;
    }

    static String generuj_date(String s, String e){
        //String s = "2016-05-30";
        //String e = "2016-06-10";
        LocalDate start = LocalDate.parse(s);
        LocalDate end = LocalDate.parse(e);
        int days = start.until(end).getDays();
        int years = start.until(end).getYears();
        int months = start.until(end).getMonths();

        /*List<LocalDate> totalDates = new ArrayList<>();
        while (!start.isAfter(end)) {
            totalDates.add(start);
            start = start.plusDays(1);
        }
        System.out.println(totalDates);*/

        return start.plusDays(rNum.nextInt(days+365*years+30*months)).toString();
    }

}
