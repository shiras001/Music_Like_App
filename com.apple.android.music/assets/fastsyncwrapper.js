
console.log("hello world from fastsyncwrapper");

import { FastSyncConnection } from "./index.js";

var fastSyncConnection = undefined;

function heartbeat(beat) {
    console.log("heartbeat() " + beat);
    SVGroupActivities.heartbeat("toc");
    return "toc"
}

function createSession(pseudonym, publicKey, nickname, connectionPushTopic, sessionPushTopic) {
    console.log("createSession() IN JS pseudonym: " + pseudonym
    + " publicKey: " + publicKey
    + " nickname: " + nickname
    + " connectionPushTopic: " + connectionPushTopic
    + " sessionPushTopic: " + sessionPushTopic);

    const length = publicKey.length;
    const publicKeyBytes = new Uint8Array(length);
    for (let i = 0; i < length; i++) {
        publicKeyBytes[i] = publicKey.charCodeAt(i);
    }

    fastSyncConnection = new FastSyncConnection(pseudonym,
                                                publicKeyBytes,
                                                nickname,
                                                connectionPushTopic,
                                                sessionPushTopic);

    console.log("createSession() register error listener...");
    fastSyncConnection.addEventListener("error", () => {
        console.log("createSession() CALLBACK we got an error?");
        SVGroupActivities.onSessionError("We got an error");
    });

    console.log("createSession() register connectionstatechange listener...");
    fastSyncConnection.addEventListener("connectionstatechange", () => {
        console.log("createSession() CALLBACK we got connectionstatechange");
        SVGroupActivities.onSessionEvent("We got a connection state change!");
    });

    console.log("createSession() register message listener...");
    fastSyncConnection.addEventListener("message", (e) => {
        console.warn('CALLBACK wow i got a real message??', e.data);
        SVGroupActivities.onSessionMessage("We got a message!");
    });

    console.log("createSession() OUT we're good!");
    return "fastsync session";
}

function isSessionActive() {
    let isDefined = fastSyncConnection != undefined;
    let notClosed = fastSyncConnection.connectionState != "closed";
    console.log("isSessionActive() isDefined: " + isDefined + " notClosed: " + notClosed);
    return isDefined && notClosed;
}


