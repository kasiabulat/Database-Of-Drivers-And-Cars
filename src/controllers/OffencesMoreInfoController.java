package controllers;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;

public class OffencesMoreInfoController {
    @FXML
    private Button showButton;
    @FXML
    private TextArea moreInfo;
    @FXML
    private TextField kierowca;

    @FXML
    public void addOffence(final ActionEvent event) {
        // TODO: adding offence to database
    }

    @FXML
    public void showInfo(final ActionEvent event) {
        // TODO: show more info basing on all three tables - mandaty_wystawiający, wykroczenia, mandaty
    }

}
