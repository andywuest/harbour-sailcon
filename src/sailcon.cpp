#include "sailcon.h"

Sailcon::Sailcon(QObject *parent) : QObject(parent), settings("harbour-sailcon", "settings") {
    this->networkAccessManager = new QNetworkAccessManager(this);
    dukeconBackend = new DukeconBackend(this->networkAccessManager, "harbour-sailcon", "0.1.0", this);
}

Sailcon::~Sailcon() {
}

DukeconBackend *Sailcon::getDukeconBackend() {
    return this->dukeconBackend;
}
