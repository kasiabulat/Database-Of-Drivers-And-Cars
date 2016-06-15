package controllers;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import javafx.scene.layout.AnchorPane;

public class ExamsStatisticsController {
    @FXML
    private AnchorPane anchorPane;

    @FXML
    private Button showInfo;

    @FXML
    private TextField typ_egzaminuTextField;

    @FXML
    private TextField kategoriaTextField;

    @FXML
    private TextField liczba_zdajacychTextField;

    @FXML
    private TextField liczba_zdajacych_kobietTextField;

    @FXML
    private TextField liczba_zdajacych_mezczyznTextField;

    @FXML
    private TextField ile_zdaloTextField;

    @FXML
    private TextField ile_zdalo_kobietTextField;

    @FXML
    private TextField ile_zdalo_mezczyznTextField;

    @FXML
    private TextField id_egzaminu;

    @FXML
    public void showInfo(final ActionEvent event) {
        //TODO: show info about exams
    }
}
