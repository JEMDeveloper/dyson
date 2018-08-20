var exec = require('cordova/exec');

var PLUGIN_NAME = "Dyson";

var Dyson = {

    setEnvironment: function (success,failure,environment) {
        exec(success, failure, PLUGIN_NAME, 'setEnvironment', [environment]);
    },

    startTransmissionOfEnrollmentEntry: function (success,failure,data) {
        var enrollmentData = data.enrollmentData;
        var messageId = data.messageId;
        var enrollmentKey = data.enrollmentKey;

        exec(success, failure, PLUGIN_NAME, 'startTransmissionOfEnrollmentEntry', [enrollmentData,messageId,enrollmentKey]);
    },

    startTransmissionOfBlob: function (success,failure,data) {
        var enrollmentData = data.enrollmentData;
        var messageId = data.messageId;
        var blobContainer = data.blobContainer;
        var enrollmentKey = data.enrollmentKey;

        exec(success, failure, PLUGIN_NAME, 'startTransmissionOfBlob', [enrollmentData,messageId,blobContainer,enrollmentKey]);
    },

    getPendingUploads: function (success,failure) {
        exec(success, failure, PLUGIN_NAME, 'getPendingUploads', []);
    },

    startTransmissionOfUploadsOnLogin: function () {
        exec(null, null, PLUGIN_NAME, 'startTransmissionOfUploadsOnLogin', []);
    }

};

module.exports = Dyson;