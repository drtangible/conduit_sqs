defmodule ConduitSQS.PollerSupervisorTest do
  use ExUnit.Case, async: true
  alias ConduitSQS.PollerSupervisor

  describe "init/1" do
    @args [
      %{
        conduitsqs_test: {ConduitSQSTest.Subscriber, [from: ["conduitsqs-test"]]},
        conduitsqs_test2: {ConduitSQSTest.Subscriber, [from: ["conduitsqs-test2", "conduitsqs-test3"]]}
      },
      []
    ]
    test "returns child specs for each queue" do
      assert {:ok, {sup_opts, child_specs}} = PollerSupervisor.init(@args)

      # {strategy, max_restarts, max_seconds}
      assert sup_opts == {:one_for_one, 3, 5}

      assert child_specs == [
        {{ConduitSQS.Poller, 0}, {ConduitSQS.Poller, :start_link,
          ["conduitsqs-test", [from: ["conduitsqs-test"]], []]},
          :permanent, 5000, :worker, [ConduitSQS.Poller]},
        {{ConduitSQS.Poller, 1}, {ConduitSQS.Poller, :start_link,
          ["conduitsqs-test2", [from: ["conduitsqs-test2", "conduitsqs-test3"]], []]},
          :permanent, 5000, :worker, [ConduitSQS.Poller]},
        {{ConduitSQS.Poller, 2}, {ConduitSQS.Poller, :start_link,
          ["conduitsqs-test3", [from: ["conduitsqs-test2", "conduitsqs-test3"]], []]},
          :permanent, 5000, :worker, [ConduitSQS.Poller]}
      ]
    end
  end
end
