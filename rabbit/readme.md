# Création du cluster rabbitmq

Pour monter le cluser swarm avec vagrant :

    make up

Une fois que le cluster swarm est monté, se connecter sur le manager-01 et
déployer la stack :

    vagrant ssh swarm-manager-01
    cd /vagrant/rabbit/
    docker stack deploy -c rabbit.yml rabbit

Ce déploiement s'appuie sur le peer discovery de rabbitmq avec consul en
backend. Il y a donc 2 services dans cette stack : consul et rabbitmq.

Il est nécessaire de créer un secret au préalable, avec par exemple la
commande :

    openssl rand -hex 20 > erlang.cookie

Contrairement à k8s et ses statefullsel, il n'est pas aisé de démarré ce genre
de dcluster dans swarm. En effet si tous les conteneurs démarrent en même temps,
on fait face à un problème de race condition. Pour contourner j'ai une astuce un
peu moisie en modifiant l'entrypoint : si le conteneur qui démarre est le
premier (au sens de numéro de task dans le service `{{.Task.Slot}}`) alors on
démarre normalement, histoire qu'il se déploie tranquilement, sinon on fait une
pause de 30 seconde pour attendre que le premier noeud soit prêt.

L'ui de consul est dispo sur le port 8500 (http://10.0.0.121:8500), celle de
rabbit sur le port 15672 (http://10.0.0.121:15672, login / mdp : guest/guest).

La configuration de rabbitmq est faite à l'aide des fichiers de conf présents
dans le dossier `conf` (monté avec un volume dans `/etc/rabbitmq/`).

## Scale du cluster

Le scale (up ou down est possible) avec par exemple :

    docker service scale consul_rabbitmq=5

# Test du cluster

## Basic

Utilisation de l'outil rabbbitmq-perf pour tester la résilience du cluster.
(https://rabbitmq.github.io/rabbitmq-perf-test/stable)

Dans un premier temps on test basiquement avec juste une file 1 producer et 2
consommateurs (dans la même stack que le cluster).

    docker stack deploy -c perf-basic.yml rabbit

Au cours du test, on bute un des node rabbit => Le node disparaît et est
reconstruit qq secondes après, il n'y a pas de perte de message.


## Complex

Une charge plus forte que le premier cas décrit ci dessus peut être appliquée
avec :

        docker stack deploy -c perf-complex.yml rabbit

De la même façon, au cours du test, on bute un des node rabbit => Le node
disparaît et est reconstruit qq secondes après, il n'y a pas de perte de
message.
